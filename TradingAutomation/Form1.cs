using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace TradingAutomation
{
    public partial class Form1 : Form
    {

        HttpWebRequest _request = null;// (HttpWebRequest)WebRequest.Create(uri);

        public Form1()
        {
            InitializeComponent();
        }

        private void textBox1_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox1_KeyPress(object sender, KeyPressEventArgs e)
        {
            
        }

        private void textBox1_KeyDown(object sender, KeyEventArgs e)
        {
            if(e.KeyCode == System.Windows.Forms.Keys.Enter)
            {
                this.webBrowser1.Url = new Uri(this.textBox1.Text);
            }
        }


        ChromeDriver cd = new ChromeDriver(@"chromedriver_win32");

        private void button1_Click(object sender, EventArgs e)
        {
            string uri = this.textBox1.Text;

            //uri + "Auth/login"
            //Run selenium
            cd.Url = uri + "Auth/login";
            cd.Navigate();
            
        }

        //Dictionary<string, Cookie> _Cookies = new Dictionary<string, Cookie>();
        CookieContainer _Cookies = null;
        Dictionary<string, OpenQA.Selenium.Cookie> _Cookie = new Dictionary<string, OpenQA.Selenium.Cookie>();
        private void button2_Click(object sender, EventArgs ee)
        {

            
            IWebElement e = cd.FindElementById("username");
            e.SendKeys(this.txtUsername.Text);
            e = cd.FindElementById("password");
            e.SendKeys(this.txtPassword.Text);
            e = cd.FindElementById("captcha");
            e.SendKeys(this.txtCaptcha.Text);
            e = cd.FindElementById("submit-btn");
            e.Click();

            _Cookies = new CookieContainer();

            //Get the cookies
            foreach (OpenQA.Selenium.Cookie c in cd.Manage().Cookies.AllCookies)
            {
                string name = c.Name;
                string value = c.Value;
                _Cookies.Add(new System.Net.Cookie(name, value, c.Path, c.Domain));
                _Cookie.Add(c.Name, c);
            }
            

            ////

            /*
            string uri = this.textBox1.Text;



            _request = (HttpWebRequest)WebRequest.Create(uri+ "Auth/login");

            _request.Method = WebRequestMethods.Http.Post;
            _request.AllowAutoRedirect = false;
            _request.CookieContainer = new CookieContainer();
            _request.KeepAlive = true;
            _request.ContentType = "application/x-www-form-urlencoded";
            _request.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.116 Safari/537.36";
            _request.Accept = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*;q=0.8,application/signed-exchange;v=b3;q=0.9";
            
            foreach (KeyValuePair<string, Cookie> c in _Cookies)
            {
                _request.CookieContainer.Add(c.Value);

            }
            string postData = this.txtLogin.Text;
            byte[] byteArray = Encoding.UTF8.GetBytes(postData);

            // Set the ContentType property of the WebRequest.
            _request.ContentType = "application/x-www-form-urlencoded";
            // Set the ContentLength property of the WebRequest.
            _request.ContentLength = byteArray.Length;

            // Get the request stream.
            Stream dataStream = _request.GetRequestStream();
            // Write the data to the request stream.
            dataStream.Write(byteArray, 0, byteArray.Length);
            // Close the Stream object.
            dataStream.Close();

            // Get the response.
            WebResponse response = _request.GetResponse();
            // Display the status.
            Console.WriteLine(((HttpWebResponse)response).StatusDescription);

            // Get the stream containing content returned by the server.
            // The using block ensures the stream is automatically closed.
            using (dataStream = response.GetResponseStream())
            {
                // Open the stream using a StreamReader for easy access.
                StreamReader reader = new StreamReader(dataStream);
                // Read the content.
                string responseFromServer = reader.ReadToEnd();
                // Display the content.
                Console.WriteLine(responseFromServer);
            }

            foreach (Cookie cook in ((HttpWebResponse)response).Cookies)
            {
                Console.WriteLine("Domain: {0}, Name: {1}, value: {2}", cook.Domain, cook.Name, cook.Value);
                this.txtResponses.Text += string.Format("Domain: {0}, Name: {1}, value: {2}", cook.Domain, cook.Name, cook.Value) + "\n";

                _Cookies.Add(cook.Name, cook);
            }
            // Close the response.
            response.Close();

            var req = (HttpWebRequest)WebRequest.Create("https://online.agah.com/#/watch/classic");
            req.Proxy = null;
            req.KeepAlive = true;
            req.UserAgent = "Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.69 Safari/537.36";
            req.CookieContainer = new CookieContainer();
            foreach (KeyValuePair<string, Cookie> c in _Cookies)
            {
                req.CookieContainer.Add(c.Value);

            }
            string src = "";
            using (var res = (HttpWebResponse)req.GetResponse())
            {
                src = new StreamReader(res.GetResponseStream()).ReadToEnd();
            }
            this.txtResponses.Text = src;
            */
        }
        /*
        protected CookieContainer Login()
        {
            string userName = "username";
            string password = "password";
            string uri = this.textBox1.Text;

            ASCIIEncoding encoding = new ASCIIEncoding();
            string postData = this.txtLogin.Text;
            byte[] postDataBytes = encoding.GetBytes(postData);

            HttpWebRequest httpWebRequest = (HttpWebRequest)WebRequest.Create(uri + "/Auth/login");

            httpWebRequest.Method = "POST";
            httpWebRequest.ContentType = "application/x-www-form-urlencoded";
            httpWebRequest.ContentLength = postDataBytes.Length;
            httpWebRequest.UserAgent = "Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.69 Safari/537.36";
            httpWebRequest.Proxy = null;
            httpWebRequest.AllowAutoRedirect = false;

            httpWebRequest.CookieContainer = new CookieContainer();

            foreach (KeyValuePair<string , Cookie> c in _Cookies)
            {
                httpWebRequest.CookieContainer.Add(c.Value);

            }

            using (var stream = httpWebRequest.GetRequestStream())
            {
                stream.Write(postDataBytes, 0, postDataBytes.Length);
                stream.Close();
            }

            var cookieContainer = new CookieContainer();

            using (var httpWebResponse = (HttpWebResponse)httpWebRequest.GetResponse())
            {
                using (var streamReader = new StreamReader(httpWebResponse.GetResponseStream()))
                {
                    foreach (Cookie cookie in httpWebResponse.Cookies)
                    {
                        cookieContainer.Add(cookie);
                    }
                }
            }

            return cookieContainer;
            
        }
        */

        private void button3_Click(object sender, EventArgs e)
        {



            string urlGenerateNonce = "https://online.agah.com/Order/GenerateNonce";
            string sNonce = SendHttpWebRequest(urlGenerateNonce , "").Replace("\"" , "");


            //Get the cookies
            foreach (OpenQA.Selenium.Cookie c in cd.Manage().Cookies.AllCookies)
            {
                string name = c.Name;
                string value = c.Value;

                OpenQA.Selenium.Cookie cOut = null;

                if (!_Cookie.TryGetValue(name, out cOut))
                {

                    _Cookies.Add(new System.Net.Cookie(name, value, c.Path, c.Domain));
                }
            }
            this.txtResponses.Text = sNonce;

            string buyUrl = @"https://online.agah.com/Order/SendOrder";

            string body = "{'orderModel':{'Id':0,'CustomerId':165255283,'CustomerTitle':'محمدعلی قادری رهقی','OrderSide':'Buy','OrderSideId':1,'Price':48438,'Quantity':100,'Value':0,'ValidityDate':null,'MinimumQuantity':null,'DisclosedQuantity':null,'ValidityType':1,'InstrumentId':25164,'InstrumentIsin':'IRO3YZTZ0001','InstrumentName':'پیزد','BankAccountId':0,'ExpectedRemainingQuantity':0,'TradedQuantity':0,'CategoryId':'d867361a-0d38-4028-5d8c-bc452abc8b55','RemainingQuantity':100,'OrderExecuterId':3},'nonce':'{Nonce}'}";
            body = body.Replace("{Nonce}", sNonce).Replace("'" , "\"");
                

            string sBuy = SendHttpWebRequest(buyUrl, body);


        }

        private string SendHttpWebRequest(string urlGenerateNonce , string sBody)
        {
            //Fire off the request
            HttpWebRequest hwr = (HttpWebRequest)HttpWebRequest.Create(urlGenerateNonce);
            hwr.CookieContainer = _Cookies;
            hwr.Method = "POST";
            //hwr.ContentType = "application/x-www-form-urlencoded";
            hwr.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.116 Safari/537.36";
            hwr.Accept = "application/json, text/plain, */*";
            hwr.AutomaticDecompression = DecompressionMethods.Deflate | DecompressionMethods.GZip | DecompressionMethods.None;
            //hwr.TransferEncoding  = new ;
            hwr.Headers.Add("Origin", "https://online.agah.com");
            hwr.Headers.Add("Sec-Fetch-Dest", "empty");
            hwr.Headers.Add("Sec-Fetch-Mode", "cors");
            hwr.Headers.Add("Sec-Fetch-Site", "same-origin");
            hwr.Headers.Add("X-Requested-With", "XMLHttpRequest");
            hwr.Headers.Add("Accept-Language", "en-US,en;q=0.9");
            hwr.KeepAlive = true;
            hwr.Referer = "https://online.agah.com/";
            StreamWriter swr = new StreamWriter(hwr.GetRequestStream());
            swr.Write(sBody);
            swr.Close();

            WebResponse wr = hwr.GetResponse();
            string s = new System.IO.StreamReader(wr.GetResponseStream()).ReadToEnd();
            return s;
        }

        private void splitContainer1_Panel2_Paint(object sender, PaintEventArgs e)
        {

        }

        private void Form1_Load(object sender, EventArgs e)
        {
            GetNamadsInfo();

            //  /data/instruments/14653842.js  //Get All Namads Ids
            //  /Watch/GetLiveSegmentation?isin=IRO3STIZ0001
            ///Watch/GetInstrumentInfo?isin=IRO3STIZ0001  اطلاعات نماد
            ///

            // get portfo info
            //https://online.agah.com/Portfolio/GetMyPortfolios?CalculateByTotalNumberOfShare=true&HideZeroAsset=true&IsLastPrice=true&filter=%7B%7D&limit=25&page=1&sort=%7B%22SecurityTitle%22:%22asc%22%7D

            //  /User/Clients get userinfo
        }


        Dictionary<string , string> _NamadsInfo = null;

        void GetNamadsInfo()
        {
            HttpWebRequest hwr = (HttpWebRequest)HttpWebRequest.Create("https://online.agah.com/data/instruments/14653844.js");
            hwr.CookieContainer = _Cookies;
            hwr.Method = "GET";
            //hwr.ContentType = "application/x-www-form-urlencoded";
            hwr.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.116 Safari/537.36";
            hwr.Accept = "application/json, text/plain, */*";
            hwr.AutomaticDecompression = DecompressionMethods.Deflate | DecompressionMethods.GZip | DecompressionMethods.None;
            //hwr.TransferEncoding  = new ;
            hwr.Headers.Add("Origin", "https://online.agah.com");
            hwr.Headers.Add("Sec-Fetch-Dest", "empty");
            hwr.Headers.Add("Sec-Fetch-Mode", "cors");
            hwr.Headers.Add("Sec-Fetch-Site", "same-origin");
            hwr.Headers.Add("X-Requested-With", "XMLHttpRequest");
            hwr.Headers.Add("Accept-Language", "en-US,en;q=0.9");
            hwr.KeepAlive = true;
            hwr.Referer = "https://online.agah.com/";

            WebResponse wr = hwr.GetResponse();
            string s = new System.IO.StreamReader(wr.GetResponseStream()).ReadToEnd();
            string[] sp = s.Split(';');

            _NamadsInfo = new Dictionary<string, string>();
            foreach(string stmp in sp)
            {
                string[] st = stmp.Split(',');

                _NamadsInfo.Add(st[4], stmp);

                this.cmbBuyNamad.Items.Add(st[4].Replace("\"" , ""));
            }

        }
    }
}
