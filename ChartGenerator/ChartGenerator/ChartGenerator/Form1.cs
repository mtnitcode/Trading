using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Drawing.Imaging;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace ChartGenerator
{
    public partial class Form1 : Form
    {

        public Form1()
        {
            InitializeComponent();
        }


        private void button1_Click(object sender, EventArgs e)
        {


            Image img = null;
            DiagramGenerator dg = new DiagramGenerator ();

            var ch = dg.GenedateRandomStatus();

            img = dg.GenerateLineHistoryImage(ch);

            this.pictureBox1.Image = img;

        }



        private Image DrawText(String text, Font font, Color textColor, Color backColor)
        {
            //first, create a dummy bitmap just to get a graphics object
            Image img = new Bitmap(1, 1);
            Graphics drawing = Graphics.FromImage(img);

            //measure the string to see how big the image needs to be
            SizeF textSize = drawing.MeasureString(text, font);

            //free up the dummy image and old graphics object
            img.Dispose();
            drawing.Dispose();

            //create a new image of the right size
            img = new Bitmap((int)textSize.Width, (int)textSize.Height);

            drawing = Graphics.FromImage(img);

            //paint the background
            drawing.Clear(backColor);

            //create a brush for the text
            Brush textBrush = new SolidBrush(textColor);

            drawing.DrawString(text, font, textBrush, 0, 0);

            drawing.Save();

            textBrush.Dispose();
            drawing.Dispose();

            return img;

        }



        private void Form1_Load(object sender, EventArgs e)
        {

            this.dataGridView1.RowTemplate.Height = 60;


        }

        private void button2_Click(object sender, EventArgs e)
        {
            List<NamadStatus> ll = new List<NamadStatus>();

            using (DiagramGenerator dg = new DiagramGenerator())
            {
                for (int i = 0; i < 10; i++)
                {

                    ll.Add(new NamadStatus { Name = i.ToString(), TodayImage = dg.GenerateHistoryImage(dg.GenedateRandomStatus()) });

                }
            }
            this.namadStatusBindingSource.DataSource = ll;


        }
    }

}
