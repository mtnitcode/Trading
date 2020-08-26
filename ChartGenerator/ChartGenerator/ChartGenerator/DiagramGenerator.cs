using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Linq;
using System.Text;
using System.Threading.Tasks;


namespace ChartGenerator
{
    public class DiagramGenerator : IDisposable
    {
        static readonly Random random = new Random();

        int ImageWidth = 150;
        int ImageHeight = 50;

        public DiagramGenerator() { 
        
        }

        public Image GenerateLineHistoryImage(OrderedDictionary data)
        {
            var _Lines  = GetLineData(data);

            Image img;
            using (Bitmap bmp = new Bitmap(ImageWidth, ImageHeight))
            {
                DrawLines(_Lines, bmp);

                img = Image.FromHbitmap(bmp.GetHbitmap());

            }
            return img;

        }

        public List<Line> GetLineData(OrderedDictionary data)
        {
            List<Line> _Lines = new List<Line>();

            //List<int> keyList = new List<int>(data.Keys);

            for (int i = 0; i < data.Count-1 ; i++)
            {
                ChangeStatus c = (ChangeStatus)data[i];
                ChangeStatus cc = (ChangeStatus)data[i + 1];

                int yS = 0;
                int yE = 0;

                if (c.BenefitChange <= 0)
                    yS = ImageHeight / 2 + (int)( Math.Abs(c.BenefitChange*100) * 5/100);
                else
                    yS = ImageHeight / 2 - (int)(Math.Abs(c.BenefitChange*100) * 5/100);

                if (cc.BenefitChange <= 0)
                    yE = ImageHeight / 2 + (int)(Math.Abs(cc.BenefitChange*100) * 5/100);
                else
                    yE = ImageHeight / 2 - (int)(Math.Abs(cc.BenefitChange*100) * 5/100);

                _Lines.Add(new Line { Start = new Point(i * 5, yS), End = new Point((i + 1) * 5, yE) });

            }
            return _Lines;
        }

        private void DrawLines(List<Line> _Lines, Bitmap bmp)
        {
            Pen pen = new Pen(Color.Gray);
            Pen penR = new Pen(Color.Red);
            Pen penG = new Pen(Color.Green);
            using (Graphics g = Graphics.FromImage(bmp))
            {
                //                    g.Clear(Color.White);
                g.DrawLine(pen, new Point(0, ImageHeight / 2), new Point(ImageWidth, ImageHeight / 2));
                foreach (Line l in _Lines)
                {
                    g.DrawLine(penG, l.Start, l.End);
                }
            }
        }

        public Image GenerateHistoryImage(OrderedDictionary data)
        {
            Image img;
            using (Bitmap bmp = new Bitmap(ImageWidth, ImageHeight))
            {
                Pen pen = new Pen(Color.Gray);
                Pen penR = new Pen(Color.Red);
                penR.Width = 5;
                Pen penG = new Pen(Color.Green);
                penG.Width = 5;
                using (Graphics g = Graphics.FromImage(bmp))
                {
                    g.Clear(Color.White);
                    g.DrawLine(pen, new Point(0, ImageHeight / 2), new Point(ImageWidth, ImageHeight / 2));

                }

                DrawChanges(data , bmp);
                DrawLines(GetLineData(data), bmp);


                Pen penW = new Pen(Color.White);
                penW.Width = 5;
                using (Graphics g = Graphics.FromImage(bmp))
                {
                    //g.DrawLine(penW, new Point(0, 0), new Point(ImageWidth, 0));
                   // g.DrawLine(penW, new Point(0, ImageHeight), new Point(ImageWidth, ImageHeight));

                }

                //bmp.Save(@"myimage.jpg", ImageFormat.Jpeg);

                img = Image.FromHbitmap(bmp.GetHbitmap());
            }

            return img;
        }


        public Image GenerateBenefitImage(BenefitStatus data)
        {
            Image img;
            using (Bitmap bmp = new Bitmap(ImageWidth, ImageHeight))
            {
                Pen pen = new Pen(Color.Gray);
                Pen penR = new Pen(Color.Red);
                penR.Width = 5;
                Pen penG = new Pen(Color.Green);
                penG.Width = 5;
                using (Graphics g = Graphics.FromImage(bmp))
                {
                    g.Clear(Color.White);

                }

                DrawBenefit(data, bmp);

                img = Image.FromHbitmap(bmp.GetHbitmap());
            }

            return img;
        }

        private double RandomNumberBetween(double minValue, double maxValue)
        {
            var next = random.NextDouble();

            return minValue + (next * (maxValue - minValue));
        }
        public  OrderedDictionary GenedateRandomStatus()
        {

            OrderedDictionary _NamadStatus = new OrderedDictionary();
            for (int i = 1; i <= 30; i++)
            {

                ChangeStatus ch = new ChangeStatus();

                ch.BenefitChange = (float)Math.Round((float)RandomNumberBetween(-4.99, 4.99) * 100f) / 100f;
                ch.BuyQueue = random.Next(100000, 9000000);
                ch.ShopQueue = random.Next(100000, 9000000);

                _NamadStatus.Insert(i-1, i.ToString(), ch);

            }
            return _NamadStatus;
        }

        private void DrawBenefit(BenefitStatus benefitStatus, Bitmap bmp)
        {
            Pen penB = new Pen(Color.Black);
            Pen penGr = new Pen(Color.Gray);
            Pen penG = new Pen(Color.GreenYellow);
            Pen penGD = new Pen(Color.Green);
            Pen penR = new Pen(Color.Orange);
            Pen penRD = new Pen(Color.Red);

            SolidBrush bB = new SolidBrush(Color.Black);
            SolidBrush bGray = new SolidBrush(Color.Gray);
            SolidBrush bdGray = new SolidBrush(Color.DarkGray);
            SolidBrush bG = new SolidBrush(Color.LightGreen);
            SolidBrush bGD = new SolidBrush(Color.DarkSeaGreen);
            SolidBrush bGDark = new SolidBrush(Color.DarkGreen);
            SolidBrush bR = new SolidBrush(Color.OrangeRed);
            SolidBrush bRD = new SolidBrush(Color.Red);

            using (Graphics g = Graphics.FromImage(bmp))
            {
                // g.Clear(Color.White);


                g.FillRectangle(bdGray, new Rectangle(0,5 , ImageWidth, ImageHeight/3));
                g.FillRectangle(bG, new Rectangle(0,(ImageHeight / 3) + 5 , ImageWidth, ImageHeight / 3));


                if (benefitStatus.TotalPortfoCost > 0)
                {
                    long res = (long)benefitStatus.CountOfPortion * benefitStatus.LastCost * ImageWidth;

                    float portionOfPortfo = (res / benefitStatus.TotalPortfoCost);

                    g.FillRectangle(bGray, new Rectangle(0, 8, (int)portionOfPortfo, (ImageHeight / 3) - 6));

                    long ben = (long)benefitStatus.CountOfPortion * (benefitStatus.LastCost - benefitStatus.BuyCost) * ImageWidth;

                    float benOfPortfo = (ben / benefitStatus.TotalPortfoBenefit);

                    if(benOfPortfo > 0)
                        g.FillRectangle(bGDark, new Rectangle(0, (ImageHeight / 3) + 10, (int)benOfPortfo, (ImageHeight / 3) - 10));
                    else
                        g.FillRectangle(bR, new Rectangle(0, (ImageHeight / 3) + 10, (int)Math.Abs(benOfPortfo), (ImageHeight / 3) - 10));


                }
                //float benefitAvverage = sumofBenefit / NamadStatus.Count;

                //RectangleF rectf = new RectangleF(100, 2, 50, 25);
                //g.SmoothingMode = SmoothingMode.AntiAlias;
                //g.InterpolationMode = InterpolationMode.HighQualityBicubic;
                //g.PixelOffsetMode = PixelOffsetMode.HighQuality;
                //g.DrawString(benefitAvverage.ToString("#.##0.00"), new Font("Tahoma", 8), Brushes.Black, rectf);

            }
        }

        private void DrawChanges(OrderedDictionary NamadStatus, Bitmap bmp)
        {
            Pen penB = new Pen(Color.Black);
            Pen penG = new Pen(Color.GreenYellow);
            Pen penGD = new Pen(Color.Green);
            Pen penR = new Pen(Color.Orange);
            Pen penRD = new Pen(Color.Red);

            SolidBrush bB = new SolidBrush(Color.Black);
            SolidBrush bG = new SolidBrush(Color.LightGreen);
            SolidBrush bGD = new SolidBrush(Color.DarkSeaGreen);
            SolidBrush bR = new SolidBrush(Color.OrangeRed);
            SolidBrush bRD = new SolidBrush(Color.Red);

            using (Graphics g = Graphics.FromImage(bmp))
            {
                // g.Clear(Color.White);

                float sumofBenefit = 0.0f;
                int day = 0;
                for (int k = 0; k< NamadStatus.Count; k++)// KeyValuePair<int, ChangeStatus> ch in NamadStatus)
                {

                    ChangeStatus ch = (ChangeStatus)NamadStatus[k];
                    sumofBenefit += ch.BenefitChange;
                    float finalY = 0.0f;

                    if (ch.BenefitChange <= 0)
                        finalY = ImageHeight / 2 +  (Math.Abs(ch.BenefitChange*100) * 5)/100;//sumofBenefit;
                    else
                        finalY = ImageHeight / 2 -  (Math.Abs(ch.BenefitChange*100) * 5)/100;//sumofBenefit;


                    int d = day++;

                    if ((int)(ch.BuyQueue / 100000) <= ImageHeight / 2)
                    {
                        g.FillRectangle(bG, new Rectangle(d * 5, ImageHeight / 2 - (int)(ch.BuyQueue / 100000), 3, (int)(ch.BuyQueue / 100000)));
                    }
                    else
                        g.FillRectangle(bGD, new Rectangle(d * 5, 0, 3, ImageHeight / 2));

                    if ((int)(ch.ShopQueue / 100000) <= ImageHeight / 2)
                        g.DrawRectangle(penR, new Rectangle(d * 5, ImageHeight / 2, 3, (int)(ch.ShopQueue / 100000)));
                    else
                        g.FillRectangle(bR, new Rectangle(d * 5, ImageHeight / 2, 3, ImageHeight / 2));

                    g.FillRectangle(bB, new Rectangle(d * 5, (int)(finalY), 3, 2));

                }

                //float benefitAvverage = sumofBenefit / NamadStatus.Count;

                //RectangleF rectf = new RectangleF(100, 2, 50, 25);
                //g.SmoothingMode = SmoothingMode.AntiAlias;
                //g.InterpolationMode = InterpolationMode.HighQualityBicubic;
                //g.PixelOffsetMode = PixelOffsetMode.HighQuality;
                //g.DrawString(benefitAvverage.ToString("#.##0.00"), new Font("Tahoma", 8), Brushes.Black, rectf);

            }
        }

        public void Dispose()
        {
            // 
        }
    }

    public struct ChangeStatus
    {
        public float BenefitChange;
        public long BuyQueue;
        public long ShopQueue;
        public int LastCost;
    }

    public struct BenefitStatus
    {


        public int LastCost;
        public int BuyCost;
        public int CountOfPortion;
        public long TotalPortfoCost;
        public long TotalPortfoBenefit;
    }


    public struct Line
    {
        public Point Start;
        public Point End;
    }

}
