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
        public Basket BasketInfo { get; set; }
        public float MyAvveragebenefitPercent { get; set; }
        public long MyAvverageBuyCost { get; set; }
        public int LastCost {get;set;}
        public float BuyQueue {get;set;}
        public float ShopQueue { get;set;}
        public string LastTradingDate { get; set; }
    }

    public class Basket
    {
        public Basket()
        {
        }

        public long OwnerName { get; set; }
        public string RealCost { get; set; }
        public long TradingDate { get; set; }
    }

}
