using ChartGenerator;
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


        public static List<PaymentStatus> GetPaymentStatus()
        {
            string sqlQuery = @"select bsk.OwnerName , (select REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,sum(amount)),1), '.00','') from Payments where OwnerName = bsk.OwnerName) TotalPayment
                                , REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,sum(bsk.cost)),1), '.00','') RemainedAmount from
                                (select ownername , sum(CountOfPortion*RealCost*-1) cost , N'خرید' ttype from basket group by OwnerName 
                                union
                                select b.OwnerName , sum(ShopCount*ShoppingCost) cost , N'فروش' ttype from BasketShopping bs inner join Basket b on b.id = bs.BasketID group by b.OwnerName 
                                union
                                select p.OwnerName , sum(Amount) cost , N'پرداخت' ttype from Payments p group by p.OwnerName ) bsk
                                group by bsk.OwnerName";

            var queryResult = null as List<PaymentStatus>;
            using (var dbn = new TradingContext())
            {

                queryResult = dbn.Database.SqlQuery<PaymentStatus>(sqlQuery).ToList();

            }
            return queryResult;

        }

        public static List<TradingStatus> GetTradingsForMembers(string sOwnerName)
        {

            string sqlQuery = @"select replace(REPLACE(dbo.GregorianToPersian(CONVERT (date, SYSDATETIMEOFFSET()) ),'-','/') , '/' ,'-') ReportDate, b.id BasketId, b.OwnerName , nmd.Name NamadDesc , nmd.namad NamadName ,
                                b.TradingDate  , b.CountOfPortion 
                                ,case when bshStatus.ShopCount is not null then b.CountOfPortion-bshStatus.ShopCount when bshStatus.ShopCount is null then b.CountOfPortion end RemainedPortion
                                , REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,b.AvverageCost),1), '.00','') AvverageCost, REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,b.RealCost),1), '.00','') RealCost
                                ,case when bshStatus.ShopCount is not null then  case when b.CountOfPortion-bshStatus.ShopCount > 0 then  REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,b.RealCost*(b.CountOfPortion-bshStatus.ShopCount)),1), '.00','') 
                                 when b.CountOfPortion-bshStatus.ShopCount = 0 then  REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,b.RealCost*(b.CountOfPortion)),1), '.00','')  end  
	                                  when bshStatus.ShopCount is null then REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,b.RealCost*(b.CountOfPortion)),1), '.00','') end TotalCost
                                , REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,nh.PayaniGheymat),1), '.00','') ToDayCost ,
                                case when b.CountOfPortion-bshStatus.ShopCount = 0 then REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,(b.RealCost*b.CountOfPortion - nh.PayaniGheymat * (b.CountOfPortion) )),1), '.00','') 
	                                 when b.CountOfPortion-bshStatus.ShopCount > 0 then   REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,(nh.PayaniGheymat * (b.CountOfPortion-bshStatus.ShopCount) - b.RealCost*(b.CountOfPortion-bshStatus.ShopCount) )),1), '.00','')
	                                 when bshStatus.ShopCount is null then REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,(nh.PayaniGheymat - b.RealCost) * (b.CountOfPortion)),1), '.00','') end BenefitAmount ,
                                case when bshStatus.ShopCount is not null then (ROUND( (convert(float, nh.PayaniGheymat) / b.RealCost)-1 , 5 ))*100 
	                                 when bshStatus.ShopCount is null then (ROUND( (convert(float, nh.PayaniGheymat) / b.RealCost)-1 , 5 ))*100 end BenefitPercent , 
                                case when bshStatus.ShopCount is not null then REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,nh.PayaniGheymat * (b.CountOfPortion-bshStatus.ShopCount)),1), '.00','') 
	                                 when bshStatus.ShopCount is null then REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,nh.PayaniGheymat * (b.CountOfPortion)),1), '.00','') end TotalMonyeAmount 
                                , b.FirstOffer ,
                                REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,nh.ShopHajm),1), '.00','') ShopAmount , REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,nh.BuyHajm),1), '.00','') BuyAmount
                                from Namad nmd
                                inner join Basket b on b.Namad = nmd.Namad
                                inner join (select max(id) maxID , NamadId from NamadHistory group by NamadId) nhStatus on nhStatus.NamadId = nmd.ID
                                left outer join (select BasketID , sum(ShopCount) ShopCount , AVG(ShoppingCost) ShopAvgCost from BasketShopping group by BasketID) bshStatus on bshStatus.BasketID = b.id
                                inner join NamadHistory nh on nh.ID = nhStatus.maxID";

            var queryResult = null as List<TradingStatus>;
            using (var dbn = new TradingContext())
            {

                queryResult = dbn.Database.SqlQuery<TradingStatus>(sqlQuery).ToList();

            }
            return queryResult;

        }

    }
}
