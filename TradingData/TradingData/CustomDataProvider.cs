﻿using ChartGenerator;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity.Infrastructure;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TradingData
{

    public class CustomDataProvider
    {




        public static List<Basket> GetMyPortionStatus()
        {
            string sqlQuery = @"select * from (
                select b.id ,b.ownerid, b.OwnerName , b.namad , nmd.id NamadId ,
                b.TradingDate  , bshStatus.ShopDate
                , case when bshStatus.ShopCount is not null then b.CountOfPortion-bshStatus.ShopCount when bshStatus.ShopCount is null then b.CountOfPortion end CountOfPortion
                ,b.AvverageCost, b.RealCost
                , b.FirstOffer , b.investmenttype , b.Description , b.GroupId , b.BrokerName ,b.MasterTransactionId
                from Namad nmd
                inner join Basket b on b.Namad = nmd.Namad
                inner join (select max(id) maxID , NamadId from NamadHistory group by NamadId) nhStatus on nhStatus.NamadId = nmd.ID
                left outer join (select BasketID , max(ShoppingDate) ShopDate , sum(ShopCount) ShopCount , AVG(ShoppingCost) ShopAvgCost from BasketShopping group by BasketID) bshStatus on bshStatus.BasketID = b.id
                inner join NamadHistory nh on nh.ID = nhStatus.maxID) as portions
	            where portions.CountOfPortion > 0
                order by OwnerName , TradingDate";

            var queryResult = null as List<Basket>;
            using (var dbn = new TradingContext())
            {

                queryResult = dbn.Baskets.SqlQuery(sqlQuery ).ToList();

            }
            return queryResult;

        }


        public static List<PortfoStatus> GetPaymentStatus(int GroupId)
        {
            var queryResult = null as List<PortfoStatus>;

            using (var ctx = new TradingContext())
            {
                ctx.Database.CommandTimeout = 180;
                var idParam = new SqlParameter
                {
                    ParameterName = "GroupId",
                    Value = GroupId
                };
                //Get student name of string type
                queryResult = ctx.Database.SqlQuery<PortfoStatus>("exec procCalculateMemberBenefits @GroupId ", idParam).ToList<PortfoStatus>();

                //Or can call SP by following way
                //var courseList = ctx.Courses.SqlQuery("exec GetCoursesByStudentId @StudentId ", idParam).ToList<Course>();

            }

            /*
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
            */
            return queryResult;

        }

        public static List<TradingStatus> GetTradingsForMembers(string sOwnerName)
        {

            string sqlQuery = @"select replace(REPLACE(dbo.GregorianToPersian(CONVERT (date, SYSDATETIMEOFFSET())),'-','/') , '/' ,'-') ReportDate, b.id BasketId, b.OwnerName , nmd.Name NamadDesc , nmd.namad NamadName ,
                                b.TradingDate  
                                , b.CountOfPortion 
                                , b.FirstOffer
                                , nh.ShopHajm ShopAmount 
                                , nh.BuyHajm BuyAmount
                                , b.AvverageCost
                                , b.RealCost
                                , convert(int ,  nh.PayaniGheymat) ToDayCost 
                                ,case when bshStatus.ShopCount is not null then convert(int, b.CountOfPortion-bshStatus.ShopCount) when bshStatus.ShopCount is null then convert ( int , b.CountOfPortion) end RemainedPortion 
                                ,case when bshStatus.ShopCount is not null then  case when b.CountOfPortion-bshStatus.ShopCount > 0 then convert(int , b.RealCost*(b.CountOfPortion-bshStatus.ShopCount))
                                 when b.CountOfPortion-bshStatus.ShopCount = 0 then convert(int , 0) end  
	                             when bshStatus.ShopCount is null then convert(int , b.RealCost*(b.CountOfPortion)) end TotalCost
                                ,case when b.CountOfPortion-bshStatus.ShopCount = 0 then nh.PayaniGheymat*b.CountOfPortion - b.RealCost * (b.CountOfPortion) 
	                                 when b.CountOfPortion-bshStatus.ShopCount > 0 then  nh.PayaniGheymat * (b.CountOfPortion-bshStatus.ShopCount) - b.RealCost*(b.CountOfPortion-bshStatus.ShopCount)
	                                 when bshStatus.ShopCount is null then (nh.PayaniGheymat - b.RealCost) * (b.CountOfPortion) end BenefitAmount 
                                ,case when bshStatus.ShopCount is not null then  nh.PayaniGheymat * (b.CountOfPortion-bshStatus.ShopCount) 
	                                 when bshStatus.ShopCount is null then nh.PayaniGheymat * (b.CountOfPortion) end TotalMonyeAmount 
                                ,case when bshStatus.ShopCount is not null then convert(float,(ROUND( (convert(float, nh.PayaniGheymat) / b.RealCost)-1 , 5 ))*100 )
	                                 when bshStatus.ShopCount is null then convert(float , (ROUND( (convert(float, nh.PayaniGheymat) / b.RealCost)-1 , 5 ))*100 ) end BenefitPercent 
                                ,b.BrokerName
                                from Namad nmd
                                inner join Basket b on b.Namad = nmd.Namad
                                inner join (select max(id) maxID , NamadId from NamadHistory group by NamadId) nhStatus on nhStatus.NamadId = nmd.ID
                                left outer join (select BasketID , sum(ShopCount) ShopCount , AVG(ShoppingCost) ShopAvgCost from BasketShopping group by BasketID) bshStatus on bshStatus.BasketID = b.id
                                inner join NamadHistory nh on nh.ID = nhStatus.maxID";

            //                                 ,
            var queryResult = null as List<TradingStatus>;
            using (var dbn = new TradingContext())
            {

                queryResult = dbn.Database.SqlQuery<TradingStatus>(sqlQuery).ToList();

            }
            return queryResult;

        }

        public static List<TradingStatus> GetBasketTotalStatus()
        {

            string sqlQuery = @"select trade.NamadName, sum(trade.RemainedPortion) CountOfPortion , trade.ToDayCost, 
                        sum(trade.TotalMonyeAmount) TotalMonyeAmount from (
                        select replace(REPLACE(dbo.GregorianToPersian(CONVERT (date, SYSDATETIMEOFFSET()) ),'-','/') , '/' ,'-') ReportDate, nmd.Name NamadDesc , nmd.namad  NamadName,
                         b.CountOfPortion 
                        ,case when bshStatus.ShopCount is not null then b.CountOfPortion-bshStatus.ShopCount when bshStatus.ShopCount is null then b.CountOfPortion end RemainedPortion
                        , convert(int , nh.AkharinGheymat) ToDayCost ,
                        case when bshStatus.ShopCount is not null then nh.AkharinGheymat * (b.CountOfPortion-bshStatus.ShopCount) 
	                         when bshStatus.ShopCount is null then nh.AkharinGheymat * (b.CountOfPortion) end TotalMonyeAmount ,
                        nh.ShopHajm ShopAmount , nh.BuyHajm BuyAmount
                        from Namad nmd
                        inner join Basket b on b.Namad = nmd.Namad
                        inner join (select max(id) maxID , NamadId from NamadHistory group by NamadId) nhStatus on nhStatus.NamadId = nmd.ID
                        left outer join (select BasketID , sum(ShopCount) ShopCount , AVG(ShoppingCost) ShopAvgCost from BasketShopping group by BasketID) bshStatus on bshStatus.BasketID = b.id
                        inner join NamadHistory nh on nh.ID = nhStatus.maxID) trade 
                        where trade.RemainedPortion > 0 group by trade.NamadName , trade.ToDayCost
                        order by trade.NamadName";

            var queryResult = null as List<TradingStatus>;
            using (var dbn = new TradingContext())
            {

                queryResult = dbn.Database.SqlQuery<TradingStatus>(sqlQuery).ToList();

            }
            return queryResult;

        }

        public static List<PaymentStatus>  GetPaymentStatusDetail ()
        {
            string sqlQuery = @"select bsk.OwnerName OwnerName , (select REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,sum(amount)),1), '.00','') from Payments where OwnerName = bsk.OwnerName and PaymentDate <= bsk.tdate) TotalPayment , bsk.tdate PaymentDate 
                                , REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,bsk.cost ),1), '.00','')RemainedAmount, bsk.ttype PaymentType from
                                (select ownername , tradingdate tdate , sum(CountOfPortion*RealCost*-1) cost , N'خرید' ttype from basket group by OwnerName , TradingDate
                                union
                                select b.OwnerName , shoppingdate tdate , sum(ShopCount*ShoppingCost) cost , N'فروش' ttype from BasketShopping bs inner join Basket b on b.id = bs.BasketID group by b.OwnerName , ShoppingDate
                                union
                                select p.OwnerName , p.PaymentDate tdate , sum(Amount) cost , N'واریز وجه' ttype from Payments p where p.TransactionType = N'واریز وجه' group by p.OwnerName , p.PaymentDate
                                union
                                select p.OwnerName , p.PaymentDate tdate , sum(Amount) cost , N'برداشت وجه' ttype from Payments p where p.TransactionType = N'برداشت وجه' group by p.OwnerName , p.PaymentDate
                                union
                                select p.OwnerName , p.PaymentDate tdate , sum(Amount) cost , N'برداشت سود' ttype from Payments p where p.TransactionType = N'برداشت سود' group by p.OwnerName , p.PaymentDate
                                ) bsk
                                order by bsk.OwnerName , bsk.tdate";

            var queryResult = null as List<PaymentStatus>;
            using (var dbn = new TradingContext())
            {

                queryResult = dbn.Database.SqlQuery<PaymentStatus>(sqlQuery).ToList();

            }
            return queryResult;
        }


        public static List<TradingHistory> GetTradingDetail()
        {
            string sqlQuery = @"select b.OwnerName ,b.id id, shoppingdate TradingDate , b.Namad , bs.ShopCount CountOfPortion , REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,sum(ShopCount*ShoppingCost)*-1),1), '.00','') TotalValue , N'فروش' TradingType from BasketShopping bs inner join Basket b on b.id = bs.BasketID group by b.OwnerName , ShoppingDate ,b.id, b.namad , bs.ShopCount 
            union
            select ownername 'خرید/فروش', id id, tradingdate TradingDate , Namad , CountOfPortion, REPLACE(CONVERT(VARCHAR, CONVERT(MONEY, sum(CountOfPortion* RealCost)),1), '.00','') TotalValue  , N'خرید' TradingType from basket group by TradingDate, id, OwnerName, Namad, CountOfPortion
            order by TradingDate , b.OwnerName , b.Namad";


            var queryResult = null as List<TradingHistory>;
            using (var dbn = new TradingContext())
            {

                queryResult = dbn.Database.SqlQuery<TradingHistory>(sqlQuery).ToList();

            }
            return queryResult;
        }
        public static List<TradingHistory> GetTotalTrading()
        {
            string sqlQuery = @"select TotalTrading.TradingDate , TotalTrading.Namad , sum(TotalTrading.CountOfPortion) CountOfPortion, REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,sum(TotalTrading.TotalValue)),1), '.00','') TotalValue, TotalTrading.TradingType from (
                            select  b.ownername , b.id , shoppingdate TradingDate , b.Namad , bs.ShopCount CountOfPortion , sum(ShopCount*ShoppingCost)*-1 TotalValue , N'فروش' TradingType from BasketShopping bs inner join Basket b on b.id = bs.BasketID group by b.OwnerName , ShoppingDate ,b.id, b.namad , bs.ShopCount 
                            union
                            select ownername 'خرید/فروش', id id, tradingdate TradingDate , Namad , CountOfPortion,  sum(CountOfPortion* RealCost) TotalValue  , N'خرید' TradingType from basket group by TradingDate, id, OwnerName, Namad, CountOfPortion
                            ) TotalTrading
                            group by TotalTrading.TradingDate , TotalTrading.Namad, TotalTrading.TradingType
                            order by  TotalTrading.Namad ,TotalTrading.TradingDate ";


            var queryResult = null as List<TradingHistory>;
            using (var dbn = new TradingContext())
            {

                queryResult = dbn.Database.SqlQuery<TradingHistory>(sqlQuery).ToList();

            }
            return queryResult;
        }
        public static List<FinanceHistory> GetFinanceTransactionDetail()
        {
            string sqlQuery = @"select bsk.OwnerName , (select REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,sum(amount)),1), '.00','') from Payments where OwnerName = bsk.OwnerName and PaymentDate <= bsk.tdate) TotalRemainedPayment , bsk.tdate TransactiontDate
                                , REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,bsk.cost),1), '.00','') Amount, bsk.ttype TransactionType from
                                (select ownername , tradingdate tdate , sum(CountOfPortion*RealCost*-1) cost , N'خرید' ttype from basket group by OwnerName , TradingDate
                                union
                                select b.OwnerName , shoppingdate tdate , sum(ShopCount*ShoppingCost) cost , N'فروش' ttype from BasketShopping bs inner join Basket b on b.id = bs.BasketID group by b.OwnerName , ShoppingDate
                                union
                                select p.OwnerName , p.PaymentDate tdate , sum(Amount) cost , N'پرداخت' ttype from Payments p group by p.OwnerName , p.PaymentDate
                                ) bsk
                                order by bsk.OwnerName , bsk.tdate";


            var queryResult = null as List<FinanceHistory>;
            using (var dbn = new TradingContext())
            {

                queryResult = dbn.Database.SqlQuery<FinanceHistory>(sqlQuery).ToList();

            }
            return queryResult;
        }


    }
}
