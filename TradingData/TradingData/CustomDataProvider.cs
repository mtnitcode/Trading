using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity.Infrastructure;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TradingData
{
    public class TradingStatus
    {
        public TradingStatus() { }

        public string ReportDate { get; set; }
        public string OwnerName { get; set; }
        public string TradingDate { get; set; }
        public string NamadName { get; set; }
        public int CountOfPortion { get; set; }
        public long RealCost { get; set; }
        public long RemainedPortion { get; set; }

    }
    public class CustomDataProvider
    {

        public static List<Basket> GetMyPortionStatus()
        {
            string sqlQuery = @"select b.id , b.OwnerName , b.namad ,
                            b.TradingDate  
                            , case when bshStatus.ShopCount is not null then b.CountOfPortion-bshStatus.ShopCount when bshStatus.ShopCount is null then b.CountOfPortion end CountOfPortion
                            ,b.AvverageCost, b.RealCost
                            , b.FirstOffer , b.investmenttype , b.Description , b.GroupId , b.BrokerName 
                            from Namad nmd
                            inner join Basket b on b.Namad = nmd.Namad
                            inner join (select max(id) maxID , NamadId from NamadHistory group by NamadId) nhStatus on nhStatus.NamadId = nmd.ID
                            left outer join (select BasketID , sum(ShopCount) ShopCount , AVG(ShoppingCost) ShopAvgCost from BasketShopping group by BasketID) bshStatus on bshStatus.BasketID = b.id
                            inner join NamadHistory nh on nh.ID = nhStatus.maxID
                            order by b.OwnerName , b.TradingDate";

            var queryResult = null as List<Basket>;
            using (var dbn = new TradingContext())
            {

                queryResult = dbn.Baskets.SqlQuery(sqlQuery ).ToList();

            }
            return queryResult;

        }

    }
}
