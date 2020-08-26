

-- محاسبه سود روزانه روی هر سهم موجود در پرتفوی
select * from (
select b.TradingDate basketDate , nh.TradingDate historyDate,b.Namad , n.ID namadid ,  nh.PayaniDarsad , b.GroupId
, case when bshStatus.ShopCount is not null then b.CountOfPortion-bshStatus.ShopCount when bshStatus.ShopCount is null then b.CountOfPortion end countOfPortion
from NamadHistory nh inner join Namad n on n.ID = nh.NamadId
inner join Basket b on b.Namad = n.Namad 
left outer join (select BasketID , sum(ShopCount) ShopCount , AVG(ShoppingCost) ShopAvgCost from BasketShopping group by BasketID) bshStatus on bshStatus.BasketID = b.id
where nh.TradingDate > b.TradingDate ) as basketHistory
where basketHistory.countOfPortion >0 and basketHistory.GroupId is not null
order by basketHistory.basketDate,  basketHistory.Namad , basketHistory.historyDate


-- ************** محاسبه سود روزانه ****************
select basketHistory.historyDate , round( avg(basketHistory.PayaniDarsad) , 5) from (
select b.TradingDate basketDate , nh.TradingDate historyDate,b.Namad , n.ID namadid ,  nh.PayaniDarsad , b.GroupId
, case when bshStatus.ShopCount is not null then b.CountOfPortion-bshStatus.ShopCount when bshStatus.ShopCount is null then b.CountOfPortion end countOfPortion
from NamadHistory nh inner join Namad n on n.ID = nh.NamadId
inner join Basket b on b.Namad = n.Namad 
left outer join (select BasketID , sum(ShopCount) ShopCount , AVG(ShoppingCost) ShopAvgCost from BasketShopping group by BasketID) bshStatus on bshStatus.BasketID = b.id
where nh.TradingDate > b.TradingDate ) as basketHistory
where basketHistory.countOfPortion >0 and basketHistory.GroupId is not null
group by basketHistory.historyDate
order by basketHistory.historyDate



--********** daily benefit with names and total inversments ************
select baskethistory.* , basketOwners.Name 
from (
select basketHistory.historyDate , round( avg(basketHistory.PayaniDarsad) , 5) payaniDarsad , (select sum(amount) from Payments where PaymentDate <=basketHistory.historyDate) amount from (
select b.TradingDate basketDate , nh.TradingDate historyDate,b.Namad , n.ID namadid ,  nh.PayaniDarsad , b.GroupId
, case when bshStatus.ShopCount is not null then b.CountOfPortion-bshStatus.ShopCount when bshStatus.ShopCount is null then b.CountOfPortion end countOfPortion
from NamadHistory nh inner join Namad n on n.ID = nh.NamadId
inner join Basket b on b.Namad = n.Namad 
left outer join (select BasketID , sum(ShopCount) ShopCount , AVG(ShoppingCost) ShopAvgCost from BasketShopping group by BasketID) bshStatus on bshStatus.BasketID = b.id
where nh.TradingDate > b.TradingDate ) as basketHistory
where basketHistory.countOfPortion >0 and basketHistory.GroupId is not null
group by basketHistory.historyDate) as baskethistory
, (select name from BasketOwner) basketOwners
order by basketOwners.Name , basketHistory.historyDate





select pay.OwnerName , pay.paymentdat , (select count(distinct tradingdate) from NamadHistory where TradingDate >= pay.PaymentDat) 
 from (select p.ownername , min(p.PaymentDate) paymentdat 
from Payments p group by p.OwnerName) as pay


----------- 222 

declare @TotalPayment as bigint;
declare @TotalBenefit as bigint;
declare @TotalDays as int;
declare @SumOfDivisionOnDays as float;
declare @GroupId as int = 1;

with totalPayment as 
(select sum(amount) totalPayment from Payments p where p.OwnerName in (select Name from BasketOwner where GroupId = @GroupId)) 
select @TotalPayment=totalPayment from totalPayment;

with totalBenefit as 
(select sum(TotalMoney.TotalMoney)-sum(totalPeyment.totalPayment) TotalBenefit from 
(select bsk.OwnerName  , (select sum(amount)
from Payments where OwnerName = bsk.OwnerName and OwnerName in (select Name from BasketOwner where GroupId = @GroupId)) totalPayment from
(select ownername , sum(CountOfPortion*RealCost*-1) cost , N'خرید' ttype from basket where GroupId = @GroupId group by OwnerName 
union
select b.OwnerName , sum(ShopCount*ShoppingCost) cost , N'فروش' ttype from BasketShopping bs inner join Basket b on b.id = bs.BasketID where b.GroupId = @GroupId group by b.OwnerName  
union
select p.OwnerName , sum(Amount) cost , N'پرداخت' ttype from Payments p where p.OwnerName in (select Name from BasketOwner where GroupId = @GroupId) group by p.OwnerName 
) bsk 
group by bsk.OwnerName) as totalPeyment
inner join 
(select totalMoney.OwnerName , sum(totalMoney.TotalMoney) TotalMoney , sum(TRealCost) TotalRealCost from (
select OwnerName , b.TradingDate , n.Namad , RealCost , nh.PayaniGheymat , 
	 case when bshStatus.ShopCount is not null then  
		case when b.CountOfPortion-bshStatus.ShopCount > 0 then  nh.PayaniGheymat*(b.CountOfPortion-bshStatus.ShopCount) 
		when b.CountOfPortion-bshStatus.ShopCount = 0 then 0  end  
	 when bshStatus.ShopCount is null then nh.PayaniGheymat*(b.CountOfPortion) end TotalMoney,
	 case when bshStatus.ShopCount is not null then  
		case when b.CountOfPortion-bshStatus.ShopCount > 0 then  b.RealCost*(b.CountOfPortion-bshStatus.ShopCount) 
		when b.CountOfPortion-bshStatus.ShopCount = 0 then 0  end  
	 when bshStatus.ShopCount is null then b.RealCost*(b.CountOfPortion) end TRealCost
from Basket  b
inner join Namad n on n.Namad = b.Namad
inner join (select max(id) maxID , NamadId from NamadHistory group by NamadId) nhStatus on nhStatus.NamadId = n.ID
inner join NamadHistory nh on nh.ID = nhStatus.maxID
left outer join (select BasketID , sum(ShopCount) ShopCount , AVG(ShoppingCost) ShopAvgCost from BasketShopping group by BasketID) bshStatus on bshStatus.BasketID = b.id
where b.GroupId = @GroupId ) as totalMoney
group by totalMoney.OwnerName) as TotalMoney on TotalMoney.OwnerName = totalPeyment.OwnerName) 
select @TotalBenefit=TotalBenefit from totalBenefit;

with totalDays as 
(select sum (days.tradingDuration) totalDays from (
select  (select count(distinct tradingdate) days from NamadHistory where TradingDate >= pay.PaymentDat) tradingDuration
 from (select p.ownername , min(p.PaymentDate) paymentdat 
from Payments p where p.OwnerName in (select Name from BasketOwner where GroupId = @GroupId) group by p.OwnerName) as pay) as days) 
select @TotalDays=totalDays from totalDays;

with sumOfdivisionOndays as
(select sum( finalClac1.divisionOnAvgDays) sumOfdivisionOndays from (
select tPayments.OwnerName , tPayments.OwnerPayment, tPaymentDuration.avgDays , round( (cast( tPayments.OwnerPayment as float)/@TotalDays)*tPaymentDuration.avgDays, 5) divisionOnAvgDays  from 
(select duration.OwnerName, avg(duration.dys) avgDays from 
(select  ownerPay.tdate ,  ownerPay.OwnerName , (select count(distinct tradingdate) from NamadHistory where TradingDate >= ownerPay.tdate) dys
from (select p.OwnerName , p.PaymentDate tdate from Payments p) ownerPay) as duration  
group by duration.OwnerName) as tPaymentDuration,
(select p.OwnerName , sum(Amount) OwnerPayment  from Payments p where p.TransactionType=N'پرداخت' and p.OwnerName in (select Name from BasketOwner where GroupId = @GroupId) group by p.OwnerName ) tPayments
where tPayments.OwnerName = tPaymentDuration.OwnerName ) as finalClac1 ,

(select totalMoney.OwnerName , sum(totalMoney.TotalMoney) TotalMoney , sum(TRealCost) TotalRealCost from 
	(select OwnerName , b.TradingDate , n.Namad , RealCost , nh.PayaniGheymat ,	

	case when bshStatus.ShopCount is not null then  
		case when b.CountOfPortion-bshStatus.ShopCount > 0 then  nh.PayaniGheymat*(b.CountOfPortion-bshStatus.ShopCount) 
		when b.CountOfPortion-bshStatus.ShopCount = 0 then 0  end  
		when bshStatus.ShopCount is null then nh.PayaniGheymat*(b.CountOfPortion) end TotalMoney,
	case when bshStatus.ShopCount is not null then  
		case when b.CountOfPortion-bshStatus.ShopCount > 0 then  b.RealCost*(b.CountOfPortion-bshStatus.ShopCount) 
		when b.CountOfPortion-bshStatus.ShopCount = 0 then 0  end  
		when bshStatus.ShopCount is null then b.RealCost*(b.CountOfPortion) end TRealCost
	from Basket  b
	inner join Namad n on n.Namad = b.Namad
	inner join (select max(id) maxID , NamadId from NamadHistory group by NamadId) nhStatus on nhStatus.NamadId = n.ID
	inner join NamadHistory nh on nh.ID = nhStatus.maxID
	left outer join (select BasketID , sum(ShopCount) ShopCount , AVG(ShoppingCost) ShopAvgCost from BasketShopping group by BasketID) bshStatus on bshStatus.BasketID = b.id where b.GroupId = @GroupId ) as totalMoney
	group by totalMoney.OwnerName) tMoney where tMoney.OwnerName = finalClac1.OwnerName
 )
select @SumOfDivisionOnDays=sumOfdivisionOndays from sumOfdivisionOndays;


--02
select tPayments.OwnerName , tPayments.OwnerPayment ,
case when tWithdrawMoney.OwnerWithdraw is null then 0 when tWithdrawMoney.OwnerWithdraw is not null then tWithdrawMoney.OwnerWithdraw end OwnerWithdraw ,
tMoney.TotalRealCost , tMoney.TotalMoney , tPaymentDuration.avgDays 
, round( (( cast( tPayments.OwnerPayment as float)/@TotalDays)*tPaymentDuration.avgDays) /@SumOfDivisionOnDays , 5) divisionOnAvgDays ,
case when tWithdrawMoney.OwnerWithdraw is null then round( (((cast( tPayments.OwnerPayment as float)/@TotalDays)*tPaymentDuration.avgDays) /@SumOfDivisionOnDays) * @TotalBenefit , 5)
	when tWithdrawMoney.OwnerWithdraw is not null then round( (((cast( tPayments.OwnerPayment as float)/@TotalDays)*tPaymentDuration.avgDays) /@SumOfDivisionOnDays) * @TotalBenefit , 5) + tWithdrawMoney.OwnerWithdraw  end FinalStatus,
	tDebtors.Debtors

 from 
(select duration.OwnerName, avg(duration.dys) avgDays from 
	(select  ownerPay.tdate ,  ownerPay.OwnerName , (select count(distinct tradingdate) from NamadHistory where TradingDate >= ownerPay.tdate) dys
	from (select p.OwnerName , p.PaymentDate tdate from Payments p) ownerPay) as duration  
	group by duration.OwnerName) as tPaymentDuration,

(select p.OwnerName , sum(Amount) OwnerPayment  from Payments p 
	where p.TransactionType=N'پرداخت' and p.OwnerName in (select Name from BasketOwner where GroupId = @GroupId) group by p.OwnerName ) tPayments,

(select totalMoney.OwnerName , sum(totalMoney.TotalMoney) TotalMoney , sum(TRealCost) TotalRealCost from 
	(select OwnerName , b.TradingDate , n.Namad , RealCost , nh.PayaniGheymat ,	

	case when bshStatus.ShopCount is not null then  
		case when b.CountOfPortion-bshStatus.ShopCount > 0 then  nh.PayaniGheymat*(b.CountOfPortion-bshStatus.ShopCount) 
		when b.CountOfPortion-bshStatus.ShopCount = 0 then 0  end  
		when bshStatus.ShopCount is null then nh.PayaniGheymat*(b.CountOfPortion) end TotalMoney,
	case when bshStatus.ShopCount is not null then  
		case when b.CountOfPortion-bshStatus.ShopCount > 0 then  b.RealCost*(b.CountOfPortion-bshStatus.ShopCount) 
		when b.CountOfPortion-bshStatus.ShopCount = 0 then 0  end  
		when bshStatus.ShopCount is null then b.RealCost*(b.CountOfPortion) end TRealCost
	from Basket  b
	inner join Namad n on n.Namad = b.Namad
	inner join (select max(id) maxID , NamadId from NamadHistory group by NamadId) nhStatus on nhStatus.NamadId = n.ID
	inner join NamadHistory nh on nh.ID = nhStatus.maxID
	left outer join (select BasketID , sum(ShopCount) ShopCount , AVG(ShoppingCost) ShopAvgCost from BasketShopping group by BasketID) bshStatus on bshStatus.BasketID = b.id where b.GroupId = @GroupId ) as totalMoney
	group by totalMoney.OwnerName) tMoney
	left outer join 
	(select p.OwnerName , sum(Amount) OwnerWithdraw  from Payments p 
	where p.TransactionType=N'برداشت' and p.OwnerName in (select Name from BasketOwner where GroupId = @GroupId) group by p.OwnerName ) tWithdrawMoney on tMoney.OwnerName = tWithdrawMoney.OwnerName,

(select bsk.OwnerName , REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,sum(bsk.cost)),1), '.00','') Debtors from
(select ownername , sum(CountOfPortion*RealCost*-1) cost , N'خرید' ttype from basket group by OwnerName 
union
select b.OwnerName , sum(ShopCount*ShoppingCost) cost , N'فروش' ttype from BasketShopping bs inner join Basket b on b.id = bs.BasketID group by b.OwnerName  
union
select p.OwnerName , sum(Amount) cost , N'پرداخت' ttype from Payments p group by p.OwnerName 
) bsk
group by bsk.OwnerName) tDebtors

where tPayments.OwnerName = tPaymentDuration.OwnerName and tMoney.OwnerName = tPayments.OwnerName  and tDebtors.OwnerName = tPayments.OwnerName ;





-- total Benefit
select sum(TotalMoney.TotalMoney)-sum(totalPeyment.totalPayment) TotalBenefit from 
(select bsk.OwnerName  , (select sum(amount)
from Payments where OwnerName = bsk.OwnerName and OwnerName in (select Name from BasketOwner where GroupId = 1)) totalPayment from
(select ownername , sum(CountOfPortion*RealCost*-1) cost  from basket where GroupId = 1 group by OwnerName 
union
select b.OwnerName , sum(ShopCount*ShoppingCost) cost from BasketShopping bs inner join Basket b on b.id = bs.BasketID where b.GroupId = 1 group by b.OwnerName  
union
select p.OwnerName , sum(Amount) cost from Payments p where p.OwnerName in (select Name from BasketOwner where GroupId = 1) group by p.OwnerName 
) bsk 
group by bsk.OwnerName) as totalPeyment
inner join 
(select totalMoney.OwnerName , sum(totalMoney.TotalMoney) TotalMoney , sum(TRealCost) TotalRealCost from (
select OwnerName , b.TradingDate , n.Namad , RealCost , nh.PayaniGheymat , 
	 case when bshStatus.ShopCount is not null then  
		case when b.CountOfPortion-bshStatus.ShopCount > 0 then  nh.PayaniGheymat*(b.CountOfPortion-bshStatus.ShopCount) 
		when b.CountOfPortion-bshStatus.ShopCount = 0 then 0  end  
	 when bshStatus.ShopCount is null then nh.PayaniGheymat*(b.CountOfPortion) end TotalMoney,
	 case when bshStatus.ShopCount is not null then  
		case when b.CountOfPortion-bshStatus.ShopCount > 0 then  b.RealCost*(b.CountOfPortion-bshStatus.ShopCount) 
		when b.CountOfPortion-bshStatus.ShopCount = 0 then 0  end  
	 when bshStatus.ShopCount is null then b.RealCost*(b.CountOfPortion) end TRealCost
from Basket  b
inner join Namad n on n.Namad = b.Namad
inner join (select max(id) maxID , NamadId from NamadHistory group by NamadId) nhStatus on nhStatus.NamadId = n.ID
inner join NamadHistory nh on nh.ID = nhStatus.maxID
left outer join (select BasketID , sum(ShopCount) ShopCount , AVG(ShoppingCost) ShopAvgCost from BasketShopping group by BasketID) bshStatus on bshStatus.BasketID = b.id
where b.GroupId = 1 ) as totalMoney
group by totalMoney.OwnerName) as TotalMoney on TotalMoney.OwnerName = totalPeyment.OwnerName




select totalMoney.OwnerName , sum(totalMoney.TotalMoney) TotalMoney , sum(TRealCost) TotalRealCost from (
select OwnerName , b.TradingDate , n.Namad , RealCost , nh.PayaniGheymat , 
	 case when bshStatus.ShopCount is not null then  
		case when b.CountOfPortion-bshStatus.ShopCount > 0 then  nh.PayaniGheymat*(b.CountOfPortion-bshStatus.ShopCount) 
		when b.CountOfPortion-bshStatus.ShopCount = 0 then 0  end  
	 when bshStatus.ShopCount is null then nh.PayaniGheymat*(b.CountOfPortion) end TotalMoney,
	 case when bshStatus.ShopCount is not null then  
		case when b.CountOfPortion-bshStatus.ShopCount > 0 then  b.RealCost*(b.CountOfPortion-bshStatus.ShopCount) 
		when b.CountOfPortion-bshStatus.ShopCount = 0 then 0  end  
	 when bshStatus.ShopCount is null then b.RealCost*(b.CountOfPortion) end TRealCost
from Basket  b
inner join Namad n on n.Namad = b.Namad
inner join (select max(id) maxID , NamadId from NamadHistory group by NamadId) nhStatus on nhStatus.NamadId = n.ID
inner join NamadHistory nh on nh.ID = nhStatus.maxID
left outer join (select BasketID , sum(ShopCount) ShopCount , AVG(ShoppingCost) ShopAvgCost from BasketShopping group by BasketID) bshStatus on bshStatus.BasketID = b.id where b.GroupId = 1) as totalMoney
group by totalMoney.OwnerName


--
select bsk.OwnerName , REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,sum(bsk.cost)),1), '.00','') 'بدهکار/بستانکار' from
(select ownername , sum(CountOfPortion*RealCost*-1) cost , N'خرید' ttype from basket group by OwnerName 
union
select b.OwnerName , sum(ShopCount*ShoppingCost) cost , N'فروش' ttype from BasketShopping bs inner join Basket b on b.id = bs.BasketID group by b.OwnerName  
union
select p.OwnerName , sum(Amount) cost , N'پرداخت' ttype from Payments p group by p.OwnerName 
) bsk
group by bsk.OwnerName


select * from (
    select b.id , b.OwnerName , b.namad ,
    b.TradingDate  , bshStatus.ShopDate
    , case when bshStatus.ShopCount is not null then b.CountOfPortion-bshStatus.ShopCount when bshStatus.ShopCount is null then b.CountOfPortion end CountOfPortion
    ,b.AvverageCost, b.RealCost
    , b.FirstOffer , b.investmenttype , b.Description , b.GroupId , b.BrokerName 
    from Namad nmd
    inner join Basket b on b.Namad = nmd.Namad
    inner join (select max(id) maxID , NamadId from NamadHistory group by NamadId) nhStatus on nhStatus.NamadId = nmd.ID
    left outer join (select BasketID , max(ShoppingDate) ShopDate , sum(ShopCount) ShopCount , AVG(ShoppingCost) ShopAvgCost from BasketShopping group by BasketID) bshStatus on bshStatus.BasketID = b.id
    inner join NamadHistory nh on nh.ID = nhStatus.maxID) as portions
	where portions.CountOfPortion > 0
    order by OwnerName , TradingDate