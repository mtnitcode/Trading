﻿using ChartGenerator;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Windows.Forms.DataVisualization.Charting;

namespace TradingData
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        FolderBrowserDialog _fb = new FolderBrowserDialog();
        private void button1_Click(object sender, EventArgs e)
        {

            if (_fb.ShowDialog() == DialogResult.OK)
            {
                //http://members.tsetmc.com/tsev2/excel/MarketWatchPlus.aspx?d=0
                HttpWebRequest request = (HttpWebRequest)WebRequest.Create("http://members.tsetmc.com/tsev2/excel/MarketWatchPlus.aspx?d=" + this.txtDate.Text);
                request.AutomaticDecompression = DecompressionMethods.Deflate | DecompressionMethods.GZip;

                HttpWebResponse response = (HttpWebResponse)request.GetResponse();
                // Get the stream associated with the response.
                Stream receiveStream = response.GetResponseStream();

                // Pipes the stream to a higher level stream reader with the required encoding format. 
                //StreamReader readStream = new StreamReader(receiveStream);
                using (Stream output = File.OpenWrite(string.Format("{0}\\{1}.xls", _fb.SelectedPath , this.txtDate.Text.Replace('/' , '-') )))
                {
                    byte[] buffer = new byte[8192];
                    int bytesRead;
                    while ((bytesRead = receiveStream.Read(buffer, 0, buffer.Length)) > 0)
                    {
                        output.Write(buffer, 0, bytesRead);
                    }
                }
            }
        }

        private void button2_Click(object sender, EventArgs e)
        {

            //http://www.tsetmc.com/tsev2/data/clienttype.aspx?i=22299894048845903


            FolderBrowserDialog fd = new FolderBrowserDialog();

            if (fd.ShowDialog() == DialogResult.OK)
            {

                HttpWebRequest request = (HttpWebRequest)WebRequest.Create(string.Format("http://www.tsetmc.com/tsev2/data/clienttype.aspx?i={0}", this.txtCode.Text));
                request.AutomaticDecompression = DecompressionMethods.Deflate | DecompressionMethods.GZip;

                HttpWebResponse response = (HttpWebResponse)request.GetResponse();

                // Pipes the stream to a higher level stream reader with the required encoding format. 
                //StreamReader readStream = new StreamReader(receiveStream);
                using (Stream dataStream = response.GetResponseStream())
                {
                    using (Stream output = File.OpenWrite(string.Format("{0}\\LegalAndPersonBill-{2}-{1}.txt", fd.SelectedPath, this.txtCode.Text, this.txtDate.Text.Replace('/', '-'))))
                    {
                        StreamReader reader = new StreamReader(dataStream);
                        string responseFromServer = reader.ReadToEnd();

                        Byte[] info = new UTF8Encoding(true).GetBytes(responseFromServer);

                        // Add some information to the file.
                        output.Write(info, 0, info.Length);

                    }
                }
                
            }
        }

        private void button3_Click(object sender, EventArgs e)
        {
            //http://www.tsetmc.com/tsev2/data/marketwatchdata.aspx?HEven=0&RefId=0
            //http://www.tsetmc.com/tsev2/data/MarketWatchInit.aspx?h=0&r=0

            if (_fb.ShowDialog() == DialogResult.OK)
            {

                HttpWebRequest request = (HttpWebRequest)WebRequest.Create("http://www.tsetmc.com/tsev2/data/MarketWatchInit.aspx?h=0&r=0");
                request.AutomaticDecompression = DecompressionMethods.Deflate | DecompressionMethods.GZip;

                HttpWebResponse response = (HttpWebResponse)request.GetResponse();

                // Pipes the stream to a higher level stream reader with the required encoding format. 
                //StreamReader readStream = new StreamReader(receiveStream);
                using (Stream dataStream = response.GetResponseStream())
                {
                    using (Stream output = File.OpenWrite(string.Format("{0}\\NamadIDs-{1}.txt", _fb.SelectedPath, this.txtDate.Text.Replace('/', '-'))))
                    {
                        StreamReader reader = new StreamReader(dataStream);
                        string responseFromServer = reader.ReadToEnd();

                        string[] lines = responseFromServer.Split(';');

                        string sTotal = "";
                        using (var db = new TradingContext())
                        {
                            Dictionary<long, NamadHistory> InsertCollection = new Dictionary<long, NamadHistory>();
                            int lineNumber = 1;
                            foreach (string l in lines)
                            {
                                if (lineNumber == 1)
                                {
                                    lineNumber++;
                                    continue;
                                }
                                lineNumber++;
                                string[] namadInfo = l.Split(',');

                                if (namadInfo.Length >= 23)
                                {
                                    string s = namadInfo[2];
                                    s = s.Replace('ی', 'ي');
                                    s = s.Replace('ک', 'ك');

                                    Namad namad = db.Namads.Where(n => n.Namad1 == s).FirstOrDefault();
                                    long namadid = 0;
                                    long tseID = 0;
                                    if (namad == null)
                                    {
                                        using (var dbn = new TradingContext())
                                        {
                                            Namad newNamad = new Namad { tseID = long.Parse(namadInfo[0] ), GeneralCode = namadInfo[1], Namad1 = s, Name = namadInfo[3]  , IndustryID= int.Parse(namadInfo[18])};

                                            dbn.Namads.Add(newNamad);
                                            dbn.SaveChanges();

                                            namadid = newNamad.ID;
                                            tseID = long.Parse(namadInfo[0]);
                                        }
                                    }
                                    else if (namad.tseID == null)
                                    {
                                        using (var dbn = new TradingContext())
                                        {
                                            namad.tseID = long.Parse(namadInfo[0]);
                                            namad.GeneralCode = namadInfo[1];
                                            tseID = long.Parse(namadInfo[0]);

                                            db.SaveChanges();

                                            namadid = namad.ID;

                                        }
                                    }
                                    else
                                    {
                                        namadid = namad.ID;
                                        tseID = long.Parse(namadInfo[0]);

                                    }
                                    if (tseID > 0)
                                    {
                                        //GetCodalAnnoucements(namadid , tseID , _fb.SelectedPath);
                                    }

                                    NamadHistory nh = new NamadHistory
                                    {
                                        AkharinGheymat = long.Parse(namadInfo[7]),
                                        AkharinDarsad = Math.Round((Math.Round((float.Parse(namadInfo[7]) / float.Parse(namadInfo[13])), 5) - 1) * 100, 5),
                                        Arzesh = long.Parse(namadInfo[10]),
                                        BishtarinGheymat = long.Parse(namadInfo[12]),
                                        Dirooz = long.Parse(namadInfo[13]),
                                        Hajm = long.Parse(namadInfo[9]),
                                        AvvalinGheymat = long.Parse(namadInfo[5]),
                                        KamtarinGheymat = long.Parse(namadInfo[11]),
                                        NamadId = namadid,
                                        PayaniGheymat = long.Parse(namadInfo[6]),
                                        Tedad = long.Parse(namadInfo[8]),
                                        TradingDate = this.txtDate.Text.Replace('/', '-'),
                                        PayaniTaghyeer = long.Parse(namadInfo[6]) - long.Parse(namadInfo[13]),
                                        PayaniDarsad = Math.Round( (Math.Round( (float.Parse(namadInfo[6]) / float.Parse(namadInfo[13]) ), 5)-1)*100 , 5)
                                    };
                                    InsertCollection.Add(tseID, nh);
                                    sTotal += l.Replace(",", ";") + "\r\n";

                                }
                                else
                                {
                                    long tTseID = long.Parse(namadInfo[0]);
                                    NamadHistory outNamadh = new NamadHistory();
                                    if (InsertCollection.TryGetValue(tTseID, out outNamadh))
                                    {
                                        if (outNamadh.BuyTedad == null)
                                        {
                                            outNamadh.BuyTedad = int.Parse(namadInfo[3]);
                                            outNamadh.ShopTedad = int.Parse(namadInfo[2]);
                                            outNamadh.BuyCost = long.Parse(namadInfo[4]);
                                            outNamadh.ShopCost = long.Parse(namadInfo[5]);
                                            outNamadh.BuyHajm = long.Parse(namadInfo[6]);
                                            outNamadh.ShopHajm = long.Parse(namadInfo[7]);
                                        }
                                    }
                                    sTotal += l.Replace(",", ";") + "\r\n";
                                }

                            }
                            foreach (KeyValuePair<long,NamadHistory> entry in InsertCollection)
                            {
                                db.NamadHistories.Add(entry.Value);

                                // do something with entry.Value or entry.Key
                            }
                            db.SaveChanges();
                        }

                        Byte[] info = new UTF8Encoding(true).GetBytes(sTotal);

                        output.Write(info,  0 , info.Length);

                        MessageBox.Show("Insersion and making file is finished");
                    }
                }

            }
        }

        private void button4_Click(object sender, EventArgs e)
        {

            //http://members.tsetmc.com/tsev2/data/InstTradeHistory.aspx?i=63917421733088077&Top=999999&A=0


            if (_fb.ShowDialog() == DialogResult.OK)
            {

                string sCode = this.txtCode.Text;

                HttpWebRequest request = (HttpWebRequest)WebRequest.Create(string.Format( "http://members.tsetmc.com/tsev2/data/InstTradeHistory.aspx?i={0}&Top=999999&A=0" ,sCode ));
                request.AutomaticDecompression = DecompressionMethods.Deflate | DecompressionMethods.GZip;

                HttpWebResponse response = (HttpWebResponse)request.GetResponse();

                // Pipes the stream to a higher level stream reader with the required encoding format. 
                //StreamReader readStream = new StreamReader(receiveStream);
                using (Stream dataStream = response.GetResponseStream())
                {
                    using (Stream output = File.OpenWrite(string.Format("{0}\\HistoryOfTrade-{1}.txt", _fb.SelectedPath, this.txtCode.Text )))
                    {
                        StreamReader reader = new StreamReader(dataStream);
                        string responseFromServer = reader.ReadToEnd();

                        string[] lines = responseFromServer.Split(';');

                        string sTotal = "";
                        foreach (string l in lines)
                        {

                            sTotal += l.Replace(",", ";") + "\r\n";

                        }
                        Byte[] info = new UTF8Encoding(true).GetBytes(sTotal);

                        output.Write(info, 0, info.Length);


                    }
                }

            }
        }

        private void button5_Click(object sender, EventArgs e)
        {
        //http://www.tsetmc.com/tsev2/data/CodalTopNew.aspx?i=63917421733088077
        //http://www.tsetmc.com/tsev2/data/CodalTopNew.aspx?i=61506294208022391

        //http://www.tsetmc.com/tsev2/data/CodalTopNew.aspx

            if (_fb.ShowDialog() == DialogResult.OK)
            {
                GetCodalAnnoucements(0 , long.Parse(this.txtCode.Text) , _fb.SelectedPath);
            }
        }

        private void GetCodalAnnoucements(long namadID,long tseID ,string selectedPath)
        {
            if (tseID > 0)
            {
                using (var dbn = new TradingContext())
                {
                    NamadNotify nf = dbn.NamadNotifies.Where(n => n.tseID == tseID).FirstOrDefault();
                    if (nf != null)
                    {
                        return;
                    }
                }
            }

            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(string.Format("http://www.tsetmc.com/tsev2/data/CodalTopNew.aspx?i={0}", tseID.ToString()));
            request.AutomaticDecompression = DecompressionMethods.Deflate | DecompressionMethods.GZip;

            HttpWebResponse response = (HttpWebResponse)request.GetResponse();

            // Pipes the stream to a higher level stream reader with the required encoding format. 
            //StreamReader readStream = new StreamReader(receiveStream);
            using (Stream dataStream = response.GetResponseStream())
            {
                //using (Stream output = File.OpenWrite(string.Format("{0}\\Announcements-{1}.txt", selectedPath, tseID.ToString())))
                {
                    StreamReader reader = new StreamReader(dataStream);
                    string responseFromServer = reader.ReadToEnd();

                    var obj = JsonConvert.DeserializeObject<dynamic>(responseFromServer);

                    using (var dbn = new TradingContext())
                    {
                        foreach (object ob in obj)
                        {
                            string title = ((JArray)ob)[3].ToString();
                            string date = ((JArray)ob)[4].ToString();

                            date = date.Replace(' ', '-').Replace('/', '-').Replace(':', '-');
                            string[] d = date.Split('-');

                            date = "";
                            foreach(string sd in d)
                            {
                                if (date != "") date += "-";
                                date +=  int.Parse(sd).ToString("D2");
                            }
                            date = "13" + date;
                            NamadNotify newNamad = new NamadNotify { tseID = tseID, Title = title , AnnounceDate = date , NamadId = namadID };
                            dbn.NamadNotifies.Add(newNamad);
                        }
                        dbn.SaveChanges();

                    }
                    //using (var dbn = new TradingContext())
                    //{
                    //    NamadNotify newNamad = new  NamadNotify { tseID = long.Parse(namadInfo[0]), GeneralCode = namadInfo[1], Namad1 = namadInfo[2], Name = namadInfo[3], IndustryID = int.Parse(namadInfo[18]) };

                    //    
                    //    

                    //    namadid = newNamad.ID;
                    //}

                    // output.Write(info, 0, info.Length);


                }
            }


        }

        private void button6_Click(object sender, EventArgs e)
        {
            //http://www.tsetmc.com/Loader.aspx?Partree=151310&Flow=1


        }

        private void button7_Click(object sender, EventArgs e)
        {
            //http://www.tsetmc.com/tsev2/excel/AdjPrice.aspx?Flow=1   -- export Excel file
            //http://www.tsetmc.com/Loader.aspx?Partree=151319&Flow=1  --- document
        }

        private void button8_Click(object sender, EventArgs e)
        {
            //http://www.tsetmc.com/Loader.aspx?Partree=15131L&i=22299894048845903
        }

        private void button9_Click(object sender, EventArgs e)
        {
            //http://www.tsetmc.com/Loader.aspx?ParTree=111C1411

            FolderBrowserDialog fd = new FolderBrowserDialog();

            if (fd.ShowDialog() == DialogResult.OK)
            {

                string sCode = this.txtCode.Text;

                HttpWebRequest request = (HttpWebRequest)WebRequest.Create("http://www.tsetmc.com/Loader.aspx?ParTree=111C1411");
                request.AutomaticDecompression = DecompressionMethods.Deflate | DecompressionMethods.GZip;

                HttpWebResponse response = (HttpWebResponse)request.GetResponse();

                // Pipes the stream to a higher level stream reader with the required encoding format. 
                //StreamReader readStream = new StreamReader(receiveStream);
                using (Stream dataStream = response.GetResponseStream())
                {
                    using (Stream output = File.OpenWrite(string.Format("{0}\\StatusOfComps-{1}.txt", fd.SelectedPath, this.txtDate.Text.Replace('/', '-'))))
                    {
                        StreamReader reader = new StreamReader(dataStream);
                        string responseFromServer = reader.ReadToEnd();

                        Byte[] info = new UTF8Encoding(true).GetBytes(responseFromServer);

                        // Add some information to the file.
                        output.Write(info, 0, info.Length);


                    }
                }

            }
        }
        OpenFileDialog _fd = new OpenFileDialog();
        private void button10_Click(object sender, EventArgs e)
        {
            if(_fd.ShowDialog() == DialogResult.OK)
            {
                string sFile = _fd.FileName;

                using (Stream output = File.OpenWrite(string.Format("{0}\\StatusOfCompany-{1}.txt", Path.GetDirectoryName(_fd.FileName), this.txtDate.Text.Replace('/', '-'))))
                {
                    string sText = File.ReadAllText(_fd.FileName);
                    sText = sText.Replace('\r', ' ').Replace('\n', ' ');
                    string[] sLiens = sText.Split('#');
                    string sTotal = "";
                    foreach(string sl in sLiens)
                    {
                        string sll = sl.Replace(',' , ';');
                        string[] sCh = sll.Split(';');
                        string slin = "";
                        foreach(string s in sCh)
                        {
                            slin += s.Trim() + ";" ;

                        }
                        sTotal += slin + "\r\n";

                    }
                    Byte[] info = new UTF8Encoding(true).GetBytes(sTotal);

                    output.Write(info, 0, info.Length);



                }

            }
            

        }

        private void button11_Click(object sender, EventArgs e)
        {
            //http://www.tsetmc.com/tsev2/res/loader.aspx?t=g&_464

            if (_fb.ShowDialog() == DialogResult.OK)
            {

                string sCode = this.txtCode.Text;

                HttpWebRequest request = (HttpWebRequest)WebRequest.Create("http://www.tsetmc.com/tsev2/res/loader.aspx?t=g&_464");
                request.AutomaticDecompression = DecompressionMethods.Deflate | DecompressionMethods.GZip;

                HttpWebResponse response = (HttpWebResponse)request.GetResponse();

                // Pipes the stream to a higher level stream reader with the required encoding format. 
                //StreamReader readStream = new StreamReader(receiveStream);
                using (Stream dataStream = response.GetResponseStream())
                {
                    using (Stream output = File.OpenWrite(string.Format("{0}\\Industries-{1}.txt", _fb.SelectedPath, this.txtDate.Text.Replace('/', '-'))))
                    {
                        StreamReader reader = new StreamReader(dataStream);
                        string responseFromServer = reader.ReadToEnd();

                        responseFromServer = responseFromServer.Replace("],[", "\r\n");
                        responseFromServer = responseFromServer.Replace("]", "");
                        responseFromServer = responseFromServer.Replace("[", "");

                        responseFromServer = responseFromServer.Replace("'", "");

                        responseFromServer = responseFromServer.Replace("var Sectors=", "");
                        

                        Byte[] info = new UTF8Encoding(true).GetBytes(responseFromServer);

                        // Add some information to the file.
                        output.Write(info, 0, info.Length);


                    }
                }

            }
        }

        private void button12_Click(object sender, EventArgs e)
        {

            //if (_fb.ShowDialog() == DialogResult.OK)
            {

                //1399%2F02%2F26
                                          //https://search.codal.ir/api/search/v2/q?&Audited=true&AuditorRef=-1&Category=-1&Childs=true&CompanyState=-1&CompanyType=-1&Consolidatable=true&FromDate=   &IsNotAudited=false&Length=-1&LetterType=-1&Mains=true&NotAudited=true&NotConsolidatable=true&PageNumber=  1&Publisher=false&ToDate=   &TracingNo=-1&search=true
                string url = string.Format("https://search.codal.ir/api/search/v2/q?&Audited=true&AuditorRef=-1&Category=-1&Childs=true&CompanyState=-1&CompanyType=-1&Consolidatable=true&FromDate={0}&IsNotAudited=false&Length=-1&LetterType=-1&Mains=true&NotAudited=true&NotConsolidatable=true&PageNumber={2}&Publisher=false&ToDate={1}&TracingNo=-1&search=true", this.txtDate.Text.Replace("/" , "%2F"), this.txtDate.Text.Replace("/", "%2F"), "1");
                //string url = string.Format("https://search.codal.ir/api/search/v2/q?&Audited=true&AuditorRef=-1&Category=-1&Childs=true&CompanyState=-1&CompanyType=-1&Consolidatable=true&IsNotAudited=false&Length=-1&LetterType=-1&Mains=true&NotAudited=true&NotConsolidatable=true&PageNumber={0}&Publisher=false&TracingNo=-1&search=false", 1);

                HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);
                //request.AutomaticDecompression = DecompressionMethods.Deflate | DecompressionMethods.GZip;

                HttpWebResponse response = (HttpWebResponse)request.GetResponse();

                // Pipes the stream to a higher level stream reader with the required encoding format. 
                //StreamReader readStream = new StreamReader(receiveStream);
                using (Stream dataStream = response.GetResponseStream())
                {
                    //using (Stream output = File.OpenWrite(string.Format("{0}\\Announcements-{1}.txt", _fb.SelectedPath, this.txtDate.Text.Replace('/', '-'))))
                    {
                        StreamReader reader = new StreamReader(dataStream);
                        string responseFromServer = reader.ReadToEnd();

                        var obj = JsonConvert.DeserializeObject<dynamic>(responseFromServer);
                        int pageCount = int.Parse(obj["Page"].ToString());
                        using (var dbn = new TradingContext())
                        {
                            for (int p = 1; p <= pageCount; p++)
                            {
                                if (p > 1)
                                {
                                    System.Threading.Thread.Sleep(2000);
                                    request = (HttpWebRequest)WebRequest.Create(url);
                                    //request.AutomaticDecompression = DecompressionMethods.Deflate | DecompressionMethods.GZip;

                                    response = (HttpWebResponse)request.GetResponse();

                                    // Pipes the stream to a higher level stream reader with the required encoding format. 
                                    //StreamReader readStream = new StreamReader(receiveStream);
                                    using (Stream dataStream1 = response.GetResponseStream())
                                    {
                                        //using (Stream output = File.OpenWrite(string.Format("{0}\\Announcements-{1}.txt", _fb.SelectedPath, this.txtDate.Text.Replace('/', '-'))))
                                        {
                                            StreamReader reader1 = new StreamReader(dataStream1);
                                            string responseFromServer1 = reader1.ReadToEnd();
                                            obj = JsonConvert.DeserializeObject<dynamic>(responseFromServer1);

                                        }
                                    }
                                }

                                foreach (dynamic ob in obj["Letters"])
                                {
                                    string title = ob["Title"].ToString();
                                    string date = ob["PublishDateTime"].ToString();
                                    //     continue;
                                    //۱۳۹۹/۰۲/۲۶ ۱۰:۳۹:۴۴
                                    date = date.Replace('۰', '0').Replace('۱', '1').Replace('۲', '2').Replace('۳', '3').Replace('۴', '4').Replace('۵', '5').Replace('۶', '6').Replace('۷', '7').Replace('۸', '8').Replace('۹', '9');
                                    date = date.Replace(' ', '-').Replace('/', '-').Replace(':', '-');
                                    string[] d = date.Split('-');

                                    date = "";
                                    foreach (string sd in d)
                                    {
                                        if (date != "") date += "-";
                                        date += int.Parse(sd).ToString("D2");
                                    }
                                    date = date.Substring(0, 16);
                                    //string s = ((JArray)ob)[1].ToString().Replace('ی' , 'ي');
                                    string sNamad = ob["Symbol"].ToString().Replace('ی', 'ي').Replace('ک', 'ك');
                                    string sCompanyName = ob["CompanyName"].ToString().Replace('ی', 'ي').Replace('ک', 'ك');
                                    Namad namad = dbn.Namads.Where(n => n.Namad1 == sNamad).FirstOrDefault();
                                    long namadid = 0;

                                    if (namad != null && date.Substring(0, 10) == this.txtDate.Text.Replace('/', '-'))
                                    {
                                        NamadNotify namadNot = dbn.NamadNotifies.Where(n => n.NamadId == namad.ID && n.AnnounceDate == date).FirstOrDefault();

                                        if (namadNot == null)
                                        {
                                            NamadNotify newNamad = new NamadNotify { NamadId = namad.ID, Title = title, AnnounceDate = date };
                                            dbn.NamadNotifies.Add(newNamad);
                                        }
                                    }
                                    else if (namad == null)
                                    {
                                        using (var dbn1 = new TradingContext())
                                        {
                                            Namad newNamad1 = new Namad { Namad1 = sNamad, Name = sCompanyName };

                                            dbn1.Namads.Add(newNamad1);
                                            dbn1.SaveChanges();

                                            namadid = newNamad1.ID;
                                        }
                                        NamadNotify newNamad = new NamadNotify { NamadId = namadid, Title = title, AnnounceDate = date };
                                        dbn.NamadNotifies.Add(newNamad);

                                    }
                                }
                            }
                            dbn.SaveChanges();
                            MessageBox.Show("Insersion and making file is finished");

                        }

                    }
                }
            }
        }

        private void button13_Click(object sender, EventArgs e)
        {

            using (var dbn1 = new TradingContext())
            {
                Basket bsk = new Basket {BrokerName = this.cmbBroker.Text,  Description = this.txtDesc.Text, AvverageCost = int.Parse(this.txtBuyAvvCost.Text)  , RealCost = int.Parse(this.txtBuyRealCost.Text) , CountOfPortion = int.Parse(this.txtBuyCont.Text)
                , InvestmentType = int.Parse(this.cmbInvestmentType.Text) , Namad = this.cmbBuyNamad.Text , OwnerName = this.cmdBuyOwner.Text , TradingDate =this.txtBuyDate.Text };

                dbn1.Baskets.Add(bsk);
                dbn1.SaveChanges();
                MessageBox.Show("Insersion Completed");

            }
        }

        private void txtTotalCost_TextChanged(object sender, EventArgs e)
        {
            try
            {
                this.txtBuyRealCost.Text = ((int)(long.Parse(this.txtTotalCost.Text) / int.Parse(this.txtBuyCont.Text))).ToString();
            }
            catch (Exception ex)
            {

                LogError(ex);
            }



        }

        private void Form1_Load(object sender, EventArgs e)
        {
            InitialErrorLogs();

            LoadColors(cboWindowsColors);
            LoadColors(cboChartBackColor);
            LoadChartTypes(cboChartTypes);

            InitialTodayNamadStatus();
            InitialMonthNamadHistory();


            this.dataGridView1.RowTemplate.Height = 60;

            using (var db = new TradingContext())
            {
                var namads = db.Namads.ToList();

                var nmds = namads.OrderBy(x => x.Namad1).ToList();

                foreach (Namad n in nmds)
                {
                    this.cmbBuyNamad.Items.Add(n.Namad1);
                    this.cmbWatchList.Items.Add(n.Namad1);
                }

                var baskets = db.Baskets.ToList();

                var bsk = baskets.OrderBy(x => x.Namad).ToList();

                foreach (Basket n in bsk)
                {
                    this.cmbBasketIds.Items.Add(n.id + "-" + n.CountOfPortion + "-" + n.OwnerName + "-" + n.Namad);
                }

                //var dbrow = db.Database.SqlQuery("select replace(REPLACE(dbo.GregorianToPersian(CONVERT (date, SYSDATETIMEOFFSET()) ),'-','/') , '/' ,'-')" , null);


            }



        }


        DataTable _dtErrors = new DataTable();
        private void InitialErrorLogs()
        {

            _dtErrors.Columns.Add("Error", typeof(string));
            _dtErrors.Columns.Add("Desc", typeof(string));
            _dtErrors.Columns.Add("time", typeof(DateTime));

            this.dataGridView2.DataSource = _dtErrors;

        }
        void LogError(Exception ex)
        {

            object[] benefs = { ex.Message, ex.StackTrace.ToString() ,  DateTime.Now};
            var row1 = _dtErrors.NewRow().ItemArray = benefs;
            _dtErrors.Rows.Add(row1);
            //this.dataGridView1.Refresh();

        }


        private void txtShopTotal_TextChanged(object sender, EventArgs e)
        {
            try
            {
                this.txtShopCost.Text = ((int)(long.Parse(this.txtShopTotal.Text) / int.Parse(this.txtShopCount.Text))).ToString();

            }
            catch (Exception ex)
            {

                LogError(ex);
            }

        }

        private void button14_Click(object sender, EventArgs e)
        {
            using (var dbn1 = new TradingContext())
            {
                BasketShopping bsk = new  BasketShopping 
                {

                    ShoppingCost = int.Parse(this.txtShopCost.Text),
                    ShopCount = int.Parse(this.txtShopCount.Text),
                    BasketID = int.Parse(this.cmbBasketIds.Text.Split('-')[0]),
                    ShoppingDate = this.txtShopDate.Text ,
                    Description = this.txtDescription.Text
                };

                dbn1.BasketShoppings.Add(bsk);
                dbn1.SaveChanges();
                this.txtDescription.Text = "";
                MessageBox.Show("Insersion Completed");

            }
        }

        private void cmbBasketIds_SelectedIndexChanged(object sender, EventArgs e)
        {
            this.txtShopCount.Text = this.cmbBasketIds.Text.Split('-')[1];
        }

        private void txtBuyRealCost_TextChanged(object sender, EventArgs e)
        {

        }

        private void txtBuyCont_TextChanged(object sender, EventArgs e)
        {
            try
            {
                this.txtTotalCost.Text = ((int)(long.Parse(this.txtBuyRealCost.Text) * int.Parse(this.txtBuyCont.Text))).ToString();
            }
            catch (Exception ex)
            {

                LogError(ex);
            }

        }

        private void timer1_Tick(object sender, EventArgs e)
        {
            this.timer1.Enabled = false;

            var operation = new ParameterizedThreadStart(ShowHistory);
            Thread bigStackThread = new Thread(operation);
            //            object obj = new { Token = Methods._token, FromState = s };

            bigStackThread.Start("");

        }

        //Dictionary<string, Image> imagesList = new Dictionary<string, Image>();
        List<NamadStatus> _namadStatuses = new List<NamadStatus>();
        static int _orderBy = 0;

        void ShowChart()
        {
            if (_TotalBenefit.Count > 0 && _TotalLoss.Count > 0)
            {
                DataTable dtBenefitComparison = new DataTable();
                dtBenefitComparison.Columns.Add("Benefit", typeof(int));
                dtBenefitComparison.Columns.Add("Loss", typeof(int));

                int bs = (int)_TotalBenefit.Sum() / _TotalBenefit.Count;
                int ls = (int)_TotalLoss.Sum() / _TotalLoss.Count;

                object[] benefs = { bs, ls };
                var row1 = dtBenefitComparison.NewRow().ItemArray = benefs;
                dtBenefitComparison.Rows.Add(row1);


                if (!string.IsNullOrEmpty(cboChartBackColor.Text))
                {
                    this.pnChart.BackColor = Color.FromName(cboChartBackColor.Text);
                    pnChart.Controls.Clear();
                    pnChart.Controls.Add(GetChart(dtBenefitComparison));
                }
            }
        }
        private Chart GetChart(DataTable dt)
        {
            Chart chart = null;
            try
            {
                pnChart.Controls.Clear();
                pnChartRelControls.Visible = true;
                WindowsCharting charting = new WindowsCharting();

                chart = charting.GenerateChart(dt, pnChart.Width, pnChart.Height, cboChartBackColor.Text, cboChartTypes.SelectedIndex);
                chart.Series["Benefit"].Color = Color.Green;
                chart.Series["Loss"].Color = Color.Red;
                chart.ChartAreas[0].Area3DStyle.Enable3D = false;
                pnChartRelControls.Visible = true;
                //return chart;
            }
            catch (Exception ex)
            {

                LogError(ex);
            }
            finally
            {
                //do nothing
            }
            return chart;
        }
        private void LoadColors(ComboBox cboControl)
        {
            var systemColors = Enum.GetNames(typeof(KnownColor));
            foreach (string color in systemColors)
            {
                cboControl.Items.Add(color);
            }
            cboControl.SelectedIndex = cboControl.SelectedIndex <= 0 ? 1 : cboControl.SelectedIndex;
        }
        //Load chart types list to the combo
        private void LoadChartTypes(ComboBox cboControl)
        {
            var chartTypes = Enum.GetNames(typeof(SeriesChartType));
            foreach (string type in chartTypes)
            {
                cboControl.Items.Add(type);
            }
            cboControl.SelectedIndex = cboControl.SelectedIndex <= 0 ? (int)SeriesChartType.Column : cboControl.SelectedIndex;
        }

        static bool ShowHistoryFinished = false;
        private void ShowHistory(object inputValue)
        {
            try
            {
                ShowHistoryFinished = false;
                List<NamadStatus> namadStatuses = new List<NamadStatus>();

                List<Basket> myTradingStatus = CustomDataProvider.GetMyPortionStatus();


                if (GetLastNamadStatus())
                {
                    foreach (string s in _NamadDiagramHistory.Keys)// var dictIndex = 0 ; dictIndex < _NamadDiagramHistory.Count - 1; dictIndex++)
                    {
                        NamadStatus n = new NamadStatus { Name = s, TodayImage = null, MonthImage = null };

                        OrderedDictionary d = (OrderedDictionary)_NamadDiagramDateHistory[s];
                        if (d != null)
                            for (int i = d.Count - 1; i >= 0; i--)
                            {

                                ChangeStatus ch = (ChangeStatus)d[i];
                                if (i > d.Count - 5)
                                {
                                    n.benefitAvverageInLastWeek += ch.BenefitChange;
                                }
                                if (i > d.Count - 10 && i <= d.Count - 5)
                                {
                                    n.benefitAvverageInLast2Week += ch.BenefitChange;
                                }
                                if (i > d.Count - 15 && i <= d.Count - 10)
                                {
                                    n.benefitAvverageInLast3Week += ch.BenefitChange;
                                }

                                n.benefitAvverateInMonth += ch.BenefitChange;
                            }

                        OrderedDictionary d2 = (OrderedDictionary)_NamadDiagramHistory[s];
                        if (d2 != null)
                        {
                            ChangeStatus ch2 = (ChangeStatus)d2[d2.Count - 1];

                            n.benefitAvverateInDay = ch2.BenefitChange;
                            n.LastCost = ch2.LastCost;
                            if (n.benefitAvverateInDay < 0) _TotalLoss.Add(n.benefitAvverateInDay);
                            if (n.benefitAvverateInDay > 0) _TotalBenefit.Add(n.benefitAvverateInDay);
                        }

                        if (myTradingStatus != null)
                        {
                            List<Basket> bs = myTradingStatus.FindAll(x => x.Namad == n.Name);

                            long sumBuy = 0;
                            long sumCount = 0;

                            foreach (Basket bb in bs)
                            {
                                sumBuy += (int)bb.RealCost;
                                sumCount += (int)bb.CountOfPortion;

                            }

                            if (bs.Count > 0)
                            {
                                n.MyAvverageBuyCost = (int)sumBuy / bs.Count;
                                n.MyAvveragebenefitPercent = (float)((n.LastCost * 100 / n.MyAvverageBuyCost) - 100);
                            }

                        }

                        namadStatuses.Add(n);
                    }

                    List<NamadStatus> namadStatuses2 = null;
                    namadStatuses2 = OrderGrid(namadStatuses);
                    if (namadStatuses2 == null) namadStatuses2 = namadStatuses;
                    lock (_namadStatuses)   // lock on the list
                    {
                        _namadStatuses.Clear();
                        _namadStatuses = namadStatuses2;
                    }

                    this.BeginInvoke(
                                new Action(() =>
                                {
                                    this.namadStatusBindingSource.DataSource = _namadStatuses;
                                    this.timer1.Enabled = true;
                                }
                                ));

                    System.GC.Collect();
                    System.GC.WaitForPendingFinalizers();

                    ShowHistoryFinished = true;

                }

            }
            catch (Exception ex)
            {

                LogError(ex);
            ShowHistoryFinished = true;

            }
        }

        private static List<NamadStatus> OrderGrid(List<NamadStatus> namadStatuses )
        {
            List<NamadStatus> namadStatuses2 = null;
            if (Form1._orderBy == 5)
            {
                namadStatuses2 = namadStatuses.OrderBy(n => n.benefitAvverageInLastWeek).ToList();
            }
            if (Form1._orderBy == 6)
            {
                namadStatuses2 = namadStatuses.OrderBy(n => n.benefitAvverateInDay).ToList();
            }
            if (Form1._orderBy == 7)
            {
                namadStatuses2 = namadStatuses.OrderBy(n => n.benefitAvverateInMonth).ToList();
            }
            if (Form1._orderBy == 8)
            {
                namadStatuses2 = namadStatuses.OrderBy(n => n.MyAvveragebenefitPercent).ToList();
            }
            if (Form1._orderBy == 0)
            {
                namadStatuses2 = namadStatuses.OrderBy(n => n.Name).ToList();
            }

            return namadStatuses2;
        }

        OrderedDictionary _NamadDiagramHistory = new OrderedDictionary() ;//  <string, SortedDictionary<int, ChangeStatus>> _NamadDiagramHistory = new SortedDictionary<string, SortedDictionary<int, ChangeStatus>>();
        OrderedDictionary _NamadDiagramDateHistory = new OrderedDictionary();// SortedDictionary<string, SortedDictionary<int, ChangeStatus>>();
        OrderedDictionary LastNamadStatus = new OrderedDictionary();// SortedDictionary<string, SortedDictionary<long, NamadHistory>>();

        List<float> _TotalBenefit = new List<float>();
        List<float>  _TotalLoss = new List<float>();

        private bool GetLastNamadStatus()
        {
            try
            {
                HttpWebRequest request = (HttpWebRequest)WebRequest.Create("http://www.tsetmc.com/tsev2/data/MarketWatchInit.aspx?h=0&r=0");
                request.AutomaticDecompression = DecompressionMethods.Deflate | DecompressionMethods.GZip;

                HttpWebResponse response = (HttpWebResponse)request.GetResponse();

                // Pipes the stream to a higher level stream reader with the required encoding format. 
                //StreamReader readStream = new StreamReader(receiveStream);
                using (Stream dataStream = response.GetResponseStream())
                {
                    //using (Stream output = File.OpenWrite(string.Format("{0}\\NamadHistory-{1}.txt", Application.StartupPath , DateTime.Now.Year + "-" + DateTime.Now.Month + "-" + DateTime.Now.Day )))
                    {
                        StreamReader reader = new StreamReader(dataStream);
                        string responseFromServer = reader.ReadToEnd();

                        string[] sLines = responseFromServer.Split(';');

                        string sTotal = "";
                        string stime = DateTime.Now.Hour.ToString("##00") + "" + DateTime.Now.Minute.ToString("##00") + "" + DateTime.Now.Second.ToString("##00");

                        var InsertCollection = ProcessLastNamadStatus( sLines, stime , out sTotal);
                        LastNamadStatus.Add(DateTime.Now.ToString(), InsertCollection);

                        /*
                        //using (var db = new TradingContext())
                        {
                            SortedDictionary<long, NamadHistory> InsertCollection = new SortedDictionary<long, NamadHistory>();

                            SortedDictionary<long, string> NamadNames = new SortedDictionary<long, string>();

                            int lineNumber = 1;
                            foreach (string l in lines)
                            {
                                if (lineNumber == 1)
                                {
                                    lineNumber++;
                                    continue;
                                }
                                lineNumber++;
                                string[] namadInfo = l.Split(',');
                                long tseID = long.Parse(namadInfo[0]);

                                if (namadInfo.Length >= 23)
                                {
                                    string s = namadInfo[2];
                                    s = s.Replace('ی', 'ي');
                                    s = s.Replace('ک', 'ك');

                                    NamadNames.Add(tseID, s);

                                    NamadHistory nh = new NamadHistory
                                    {
                                        AkharinGheymat = long.Parse(namadInfo[7]),
                                        AkharinDarsad = Math.Round((Math.Round((float.Parse(namadInfo[7]) / float.Parse(namadInfo[13])), 5) - 1) * 100, 5),
                                        Arzesh = long.Parse(namadInfo[10]),
                                        BishtarinGheymat = long.Parse(namadInfo[12]),
                                        Dirooz = long.Parse(namadInfo[13]),
                                        Hajm = long.Parse(namadInfo[9]),
                                        AvvalinGheymat = long.Parse(namadInfo[5]),
                                        KamtarinGheymat = long.Parse(namadInfo[11]),
                                        NamadId = 0,
                                        PayaniGheymat = long.Parse(namadInfo[6]),
                                        Tedad = long.Parse(namadInfo[8]),
                                        TradingDate = this.txtDate.Text.Replace('/', '-'),
                                        PayaniTaghyeer = long.Parse(namadInfo[6]) - long.Parse(namadInfo[13]),
                                        PayaniDarsad = Math.Round((Math.Round((float.Parse(namadInfo[6]) / float.Parse(namadInfo[13])), 5) - 1) * 100, 5)
                                    };

                                    InsertCollection.Add(tseID, nh);
                                    sTotal += l.Replace(",", ";") + "\r\n";

                                }
                                else
                                {
                                    long tTseID = long.Parse(namadInfo[0]);
                                    NamadHistory outNamadh = new NamadHistory();
                                    if (InsertCollection.TryGetValue(tTseID, out outNamadh))
                                    {
                                        if (outNamadh.BuyTedad == null)
                                        {
                                            int ival = 0;
                                            outNamadh.BuyTedad = int.Parse(namadInfo[3]);
                                            outNamadh.ShopTedad = int.Parse(namadInfo[2]);
                                            outNamadh.BuyCost = long.Parse(namadInfo[4]);
                                            outNamadh.ShopCost = long.Parse(namadInfo[5]);
                                            outNamadh.BuyHajm = long.Parse(namadInfo[6]);
                                            if (int.TryParse(namadInfo[7], out ival)) outNamadh.ShopHajm = long.Parse(namadInfo[7]);
                                            else outNamadh.ShopHajm = 0;
                                        }
                                    }
                                    sTotal += l.Replace(",", ";") + "\r\n";
                                }

                            }
                            List<string> watchList = File.ReadAllLines(Application.StartupPath + "\\watchList.txt").ToList();

                            foreach (KeyValuePair<long, NamadHistory> h in InsertCollection)
                            {

                                string namadName = "";

                                if (NamadNames.TryGetValue(h.Key, out namadName))
                                {

                                    if (!watchList.Contains(namadName)) continue;

                                    OrderedDictionary outVal = null;

                                    if (namadName != "")
                                    {
                                        if (_NamadDiagramHistory[namadName] != null)
                                        {

                                            outVal = (OrderedDictionary)_NamadDiagramHistory[namadName];

                                            outVal.Insert(outVal.Count, stime, new ChangeStatus { BenefitChange = (float)h.Value.PayaniDarsad, ShopQueue = (long)h.Value.ShopHajm, BuyQueue = (long)h.Value.BuyHajm });
                                            while (outVal.Count > 30)
                                            {
                                                outVal.RemoveAt(0);
                                            }

                                        }
                                        else
                                        {
                                            OrderedDictionary Val = new OrderedDictionary();
                                            Val.Insert(0 , stime , new ChangeStatus { BenefitChange = (float)h.Value.PayaniDarsad, ShopQueue = (long)h.Value.ShopHajm, BuyQueue = (long)h.Value.BuyHajm });

                                            _NamadDiagramHistory.Add(namadName, Val);
                                        }
                                    }
                                }
                            }

                            LastNamadStatus.Add(DateTime.Now.ToString(), InsertCollection);

                        }
*/
                        File.WriteAllText(string.Format("{0}\\History\\NamadHistory-{1}.history", Application.StartupPath, DateTime.Now.Year + "" + DateTime.Now.Month + "" + DateTime.Now.Day + "-" + DateTime.Now.Hour.ToString("##00") + "" + DateTime.Now.Minute.ToString("##00") + "" + DateTime.Now.Second.ToString("##00")), sTotal);

                        //                    Byte[] info = new UTF8Encoding(true).GetBytes(sTotal);
                        //                    output.Write(info, (int)output.Length-1, info.Length);
                    }

                }
                return true;
            }
            catch (Exception ex)
            {

                LogError(ex);
                return false;
            }
        }

        private void InitialTodayNamadStatus()
        {

            string[] files = Directory.GetFiles(Application.StartupPath+"\\History");

            foreach(string filename in files)
            {
                if(Path.GetExtension(filename) == ".history")
                {
                    string[] sLines = File.ReadAllLines(filename);
                    string stime = Path.GetFileNameWithoutExtension(filename).Split('-')[2];
                    //using (var db = new TradingContext())
                    string sTotal = "";
                    var InsertCollection = ProcessLastNamadStatus(sLines, stime , out sTotal);
                    string fname = Path.GetFileName(filename);
                    LastNamadStatus.Add(fname.Split('-')[2], InsertCollection);

                }

            }
        }

        private SortedDictionary<long, NamadHistory> ProcessLastNamadStatus(string[] sLines, string stime , out string  sTotal )
        {

            sTotal = "";
            SortedDictionary<long, NamadHistory> InsertCollection = new SortedDictionary<long, NamadHistory>();

            SortedDictionary<long, string> NamadNames = new SortedDictionary<long, string>();

            int lineNumber = 1;
            foreach (string l in sLines)
            {
                if (lineNumber == 1)
                {
                    lineNumber++;
                    continue;
                }
                lineNumber++;
                string[] namadInfo = l.Split(',');
                long tseID = long.Parse(namadInfo[0]);

                if (namadInfo.Length >= 23)
                {
                    string s = namadInfo[2];
                    s = s.Replace('ی', 'ي');
                    s = s.Replace('ک', 'ك');

                    NamadNames.Add(tseID, s);

                    NamadHistory nh = new NamadHistory
                    {
                        AkharinGheymat = long.Parse(namadInfo[7]),
                        AkharinDarsad = Math.Round((Math.Round((float.Parse(namadInfo[7]) / float.Parse(namadInfo[13])), 5) - 1) * 100, 5),
                        Arzesh = long.Parse(namadInfo[10]),
                        BishtarinGheymat = long.Parse(namadInfo[12]),
                        Dirooz = long.Parse(namadInfo[13]),
                        Hajm = long.Parse(namadInfo[9]),
                        AvvalinGheymat = long.Parse(namadInfo[5]),
                        KamtarinGheymat = long.Parse(namadInfo[11]),
                        NamadId = 0,
                        PayaniGheymat = long.Parse(namadInfo[6]),
                        Tedad = long.Parse(namadInfo[8]),
                        TradingDate = this.txtDate.Text.Replace('/', '-'),
                        PayaniTaghyeer = long.Parse(namadInfo[6]) - long.Parse(namadInfo[13]),
                        PayaniDarsad = Math.Round((Math.Round((float.Parse(namadInfo[6]) / float.Parse(namadInfo[13])), 5) - 1) * 100, 5)
                    };
                    InsertCollection.Add(tseID, nh);
                    sTotal += l + "\r\n";

                }
                else
                {
                    long tTseID = long.Parse(namadInfo[0]);
                    NamadHistory outNamadh = new NamadHistory();
                    if (InsertCollection.TryGetValue(tTseID, out outNamadh))
                    {
                        if (outNamadh.BuyTedad == null)
                        {
                            outNamadh.BuyTedad = int.Parse(namadInfo[3]);
                            outNamadh.ShopTedad = int.Parse(namadInfo[2]);
                            outNamadh.BuyCost = long.Parse(namadInfo[4]);
                            outNamadh.ShopCost = long.Parse(namadInfo[5]);
                            outNamadh.BuyHajm = long.Parse(namadInfo[6]);
                            int ival = 0;
                            if (int.TryParse(namadInfo[7], out ival)) outNamadh.ShopHajm = long.Parse(namadInfo[7]);
                            else outNamadh.ShopHajm = 0;
                        }

                    }
                    sTotal += l + "\r\n";

                }

            }

            List<string> watchList = File.ReadAllLines(Application.StartupPath + "\\watchList.txt").ToList();

            foreach (KeyValuePair<long, NamadHistory> h in InsertCollection)
            {

                string namadName = "";

                if (NamadNames.TryGetValue(h.Key, out namadName))
                {
                    if (!watchList.Contains(namadName)) continue;

                    OrderedDictionary outVal = null;

                    if (namadName != "")
                    {
                        if (_NamadDiagramHistory[namadName] != null)
                        {
                            outVal = (OrderedDictionary)_NamadDiagramHistory[namadName];

                            outVal.Insert(outVal.Count, stime, new ChangeStatus { LastCost = (int)h.Value.PayaniGheymat, BenefitChange = (float)h.Value.PayaniDarsad, ShopQueue = (long)h.Value.ShopHajm, BuyQueue = (long)h.Value.BuyHajm });
                        }
                        else
                        {
                            OrderedDictionary Val = new OrderedDictionary();
                            Val.Insert(0, stime, new ChangeStatus { LastCost = (int)h.Value.PayaniGheymat, BenefitChange = (float)h.Value.PayaniDarsad, ShopQueue = (long)h.Value.ShopHajm, BuyQueue = (long)h.Value.BuyHajm });

                            _NamadDiagramHistory.Insert(0, namadName, Val);
                        }
                    }
                }
            }

            return InsertCollection;



        }

        private void InitialMonthNamadHistory()
        {

            _NamadDiagramDateHistory.Clear();

            for (int i = 4; i<=5; i++)
            {
                for (int j = 1; j <= 31; j++)
                {
                    GetNamadHistoryByDate("1399-" + i.ToString("##00") + "-" + j.ToString("##00"));
                }
            }
        }

        private void GetNamadHistoryByDate(string sdate)
        {

            List<string> watchList = File.ReadAllLines(Application.StartupPath + "\\watchList.txt").ToList();

            using (var dbn = new TradingContext())
            {
                List<Namad> namads = dbn.Namads.ToList();

                List<NamadHistory> hs = dbn.NamadHistories.Where(n => n.TradingDate.Contains(sdate)).ToList();

                foreach (NamadHistory h in hs)
                {

                    var n = namads.Find(f => f.ID == h.NamadId);
                    if (!watchList.Contains(n.Namad1)) continue;

                    OrderedDictionary outVal = null;

                    if (_NamadDiagramDateHistory[n.Namad1] != null)
                    {

                        outVal = (OrderedDictionary)_NamadDiagramDateHistory[n.Namad1];
                        if(outVal[sdate] == null)
                            outVal.Insert(outVal.Count , sdate , new ChangeStatus { BenefitChange = (float)h.PayaniDarsad, ShopQueue = (long)h.ShopHajm, BuyQueue = (long)h.BuyHajm });

                        while (outVal.Count > 30)
                        {
                            outVal.RemoveAt(0);
                        }
                    }
                    else
                    {
                        OrderedDictionary Val = new OrderedDictionary();
                        Val.Insert(0, sdate, new ChangeStatus { BenefitChange = (float)h.PayaniDarsad, ShopQueue = (long)h.ShopHajm, BuyQueue = (long)h.BuyHajm });
                        _NamadDiagramDateHistory.Add(n.Namad1, Val);
                    }
                }
            }
        }
        private void dataGridView1_CellPainting(object sender, DataGridViewCellPaintingEventArgs e)
        {
            try
            {
                if (e.RowIndex == -1) return;
                if (e.ColumnIndex == 1)
                {

                    if (e.RowIndex >= 0 && _namadStatuses.Count > 0 && _NamadDiagramHistory[_namadStatuses[e.RowIndex].Name] != null)
                    {
                        OrderedDictionary val = (OrderedDictionary)_NamadDiagramHistory[_namadStatuses[e.RowIndex].Name];
                        if (((DataGridViewImageCell)this.dataGridView1.Rows[e.RowIndex].Cells[1]).Value == null)
                        {

                            using (DiagramGenerator dg = new DiagramGenerator())
                            {
                                //for (int i = 0; i < 10; i++)
                                {

                                    Image img = null;
                                    try
                                    {
                                        img = dg.GenerateHistoryImage(val);
                                        if (img != null)
                                            ((DataGridViewImageCell)this.dataGridView1.Rows[e.RowIndex].Cells[1]).Value = img;

                                    }
                                    catch (Exception ex)
                                    {

                                        LogError(ex);
                                    }
                                }
                            }
                        }

                        //    KeyValuePair<string, Dictionary<int, ChangeStatus>> s in NamadDiagramHistory
                    }

                }

                if (e.ColumnIndex == 2)
                {
                    if (e.RowIndex >= 0 && _namadStatuses.Count > 0 && _NamadDiagramDateHistory[_namadStatuses[e.RowIndex].Name] != null)
                    {
                        OrderedDictionary val = (OrderedDictionary)_NamadDiagramDateHistory[_namadStatuses[e.RowIndex].Name];

                        if (((DataGridViewImageCell)this.dataGridView1.Rows[e.RowIndex].Cells[2]).Value == null)
                        {

                            using (DiagramGenerator dg = new DiagramGenerator())
                            {
                                //for (int i = 0; i < 10; i++)
                                {

                                    Image img = null;
                                    try
                                    {
                                        img = dg.GenerateHistoryImage(val);
                                        if (img != null)
                                            ((DataGridViewImageCell)this.dataGridView1.Rows[e.RowIndex].Cells[2]).Value = img;

                                    }
                                    catch (Exception ex)
                                    {

                                        LogError(ex);
                                    }
                                }
                            }
                        }

                        //    KeyValuePair<string, Dictionary<int, ChangeStatus>> s in NamadDiagramHistory
                    }

                }

                if (e.ColumnIndex == 3 && e.Value != null)
                {
                    if ((float)e.Value > 10)
                        e.CellStyle.BackColor = Color.Green;
                    if ((float)e.Value > 0 && (float)e.Value <= 10)
                        e.CellStyle.BackColor = Color.GreenYellow;
                    if ((float)e.Value < -10)
                        e.CellStyle.BackColor = Color.Red;
                    if ((float)e.Value < 0 && (float)e.Value >= -10)
                        e.CellStyle.BackColor = Color.OrangeRed;
                }
                if (e.ColumnIndex == 5 && e.Value != null)
                {
                    if ((float)e.Value > 10)
                        e.CellStyle.BackColor = Color.Green;
                    if ((float)e.Value > 0 && (float)e.Value <= 10)
                        e.CellStyle.BackColor = Color.GreenYellow;
                    if ((float)e.Value < -10)
                        e.CellStyle.BackColor = Color.Red;
                    if ((float)e.Value < 0 && (float)e.Value >= -10)
                        e.CellStyle.BackColor = Color.OrangeRed;
                }
                if (e.ColumnIndex == 4 && e.Value != null)
                {
                    if ((float)e.Value > 10)
                        e.CellStyle.BackColor = Color.Green;
                    if ((float)e.Value > 0 && (float)e.Value <= 10)
                        e.CellStyle.BackColor = Color.GreenYellow;
                    if ((float)e.Value < -10)
                        e.CellStyle.BackColor = Color.Red;
                    if ((float)e.Value < 0 && (float)e.Value >= -10)
                        e.CellStyle.BackColor = Color.OrangeRed;
                }
                if (e.ColumnIndex == 6 && e.Value != null)
                {
                    if ((float)e.Value > 2.5)
                        e.CellStyle.BackColor = Color.Green;
                    if ((float)e.Value > 0 && (float)e.Value <= 2.5)
                        e.CellStyle.BackColor = Color.GreenYellow;
                    if ((float)e.Value < -2.5)
                        e.CellStyle.BackColor = Color.Red;
                    if ((float)e.Value < 0 && (float)e.Value > -2.5)
                        e.CellStyle.BackColor = Color.OrangeRed;
                }
                if (e.ColumnIndex == 10 && e.Value != null && ((DataGridViewTextBoxCell)this.dataGridView1.Rows[e.RowIndex].Cells[9]).Value != null)
                    if (int.Parse(e.Value.ToString()) > (int)((DataGridViewTextBoxCell)this.dataGridView1.Rows[e.RowIndex].Cells[9]).Value)
                        e.CellStyle.BackColor = Color.OrangeRed;
                    else
                        e.CellStyle.BackColor = Color.GreenYellow;

            }
            catch (Exception ex)
            {

                LogError(ex);
            }
        }

        private void dataGridView1_RowsAdded(object sender, DataGridViewRowsAddedEventArgs e)
        {

        }

        private void dataGridView1_CellValueNeeded(object sender, DataGridViewCellValueEventArgs e)
        {
           
        }

        private void dataGridView1_CellValidated(object sender, DataGridViewCellEventArgs e)
        {
            
        }

        private void deleteFromWatchListToolStripMenuItem_Click(object sender, EventArgs e)
        {

            string selectednamad = this.dataGridView1.SelectedRows[0].Cells[0].Value.ToString();

            List<string> watchList = File.ReadAllLines(Application.StartupPath + "\\watchList.txt").ToList();

            List<string> newList = new List<string>();

            foreach(string s in watchList)
            {
                if(s != selectednamad)
                {
                    newList.Add(s);
                }

            }

            File.WriteAllLines(Application.StartupPath + "\\watchList.txt" , newList.ToArray());

            
        }

        private void button15_Click(object sender, EventArgs e)
        {
            List<string> watchList = File.ReadAllLines(Application.StartupPath + "\\watchList.txt").ToList();

            watchList.Add(this.cmbWatchList.Text);

            File.WriteAllLines(Application.StartupPath + "\\watchList.txt", watchList.ToArray());
        }


        private void button16_Click(object sender, EventArgs e)
        {
            this.timer1.Enabled = false;

        }

        private void button17_Click(object sender, EventArgs e)
        {
            this.timer1.Enabled = true;

            InitialMonthNamadHistory();

            var operation = new ParameterizedThreadStart(ShowHistory);
            Thread bigStackThread = new Thread(operation);
            //            object obj = new { Token = Methods._token, FromState = s };

            bigStackThread.Start("");
        }

        private void timer2_Tick(object sender, EventArgs e)
        {
            if (ShowHistoryFinished)
            {
                ShowChart();
                ShowHistoryFinished = false;
            }
        }

        private void dataGridView1_ColumnHeaderMouseClick(object sender, DataGridViewCellMouseEventArgs e)
        {

            Form1._orderBy = e.ColumnIndex;

            List<NamadStatus> namadStatuses2 = null;
            namadStatuses2 = OrderGrid(_namadStatuses);
            if (namadStatuses2 != null)
            {
                lock (_namadStatuses)   // lock on the list
                {
                    _namadStatuses.Clear();
                    _namadStatuses = namadStatuses2;
                }

                this.namadStatusBindingSource.DataSource = _namadStatuses;
            }
        }
    }
}
