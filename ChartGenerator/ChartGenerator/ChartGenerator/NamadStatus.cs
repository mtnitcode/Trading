using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ChartGenerator
{
    public class NamadStatus
    {

        public NamadStatus()
        {

        }

        public string Name { get; set; }
        public string Industry { get; set; }
        public Image TodayImage { get; set; }
        public Image MonthImage { get; set; }
        public float benefitAvverateInDay { get; set; }
        public float benefitAvverateInMonth { get; set; }
        public float benefitAvverageInLastWeek { get; set; }
        public float benefitAvverageInLast2Week { get; set; }
        public float benefitAvverageInLast3Week { get; set; }
        public long MyBenefit { get; set; }
        public string LastMytradeDate { get; set; }
        public long LastTradigCost { get; set; }
        public long LastBuyAmount { get; set; }
        public long LastShoppingAmount { get; set; }
    }
}
