using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ChartGenerator
{
    public class TradingStatus
    {
        public TradingStatus()
        {

        }
        public string ReportDate { get; set; }
        public long BasketId { get; set; }
        public string OwnerName { get; set; }
        public string NamadDesc { get; set; }
        public string NamadName { get; set; }
        public string TradingDate { get; set; }
        public int AvverageCost { get; set; }
        public int RealCost { get; set; }
        public int CountOfPortion { get; set; }
        public bool? FirstOffer { get; set; }
        public int RemainedPortion { get; set; }
        public int TotalCost { get; set; }
        public int ToDayCost { get; set; }
        public long BenefitAmount { get; set; }
        public double BenefitPercent { get; set; }
        public long TotalMonyeAmount { get; set; }
        public long? BuyAmount { get; set; }
        public long? ShopAmount { get; set; }
        public string BrokerName { get; set; }

    }

    public class NamadStatus
    {
        public NamadStatus()
        {

        }
        public string Name { get; set; }
        public string Industry { get; set; }
        public Image TodayImage { get; set; }
        public Image MonthImage { get; set; }
        public Image MoneyAndBenefitImage { get; set; }
        public float benefitAvverateInLast2Days { get; set; }
        public float benefitAvverateInDay { get; set; }
        public float benefitAvverateInMonth { get; set; }
        public float benefitAvverageInLastWeek { get; set; }
        public float benefitAvverageInLast2Week { get; set; }
        public float benefitAvverageInLast3Week { get; set; }
        public Basket BasketInfo { get; set; }
        public float MyAvveragebenefitPercent { get; set; }
        public long MyAvverageBuyCost { get; set; }
        public long TotalCostOfPortion { get; set; }
        public int LastCost { get; set; }
        public int CountOfPortion { get; set; }
        public float BuyQueue { get; set; }
        public float ShopQueue { get; set; }
        public string LastTradingDate { get; set; }
        public string StatusDesc{get;set;}
        public int BenefitCategory { get; set; }

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

    public class PaymentStatus
    {
        public PaymentStatus()
        {

        }

        public string OwnerName { get; set; }
        public string TotalPayment { get; set; }
        public string RemainedAmount { get; set; }
        public string PaymentDate { get; set; }
        public string PaymentType { get; set; }
    }
}
