using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace TradingData
{
    public partial class SQLData : Form
    {
        public SQLData()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            using (var db = new TradingContext())
            {

                NamadHistory nh = new NamadHistory
                {
                    AkharinDarsad = 1,
                    AkharinGheymat = 1,
                    AkharinTaghyeer = 1,
                    Arzesh = 1,
                    AvvalinGheymat = 1,
                    BishtarinGheymat = 1,
                    Dirooz = 1,
                    Hajm = 1,
                    KamtarinGheymat = 1,
                    NamadId = 1,
                    PayaniDarsad = 1,
                    PayaniGheymat = 1,
                    PayaniTaghyeer = 1,
                    Tedad = 1,
                    TradingDate = "asdfas"
                };

                db.NamadHistories.Add(nh);
                db.SaveChanges();
            }
        }
    }
}
