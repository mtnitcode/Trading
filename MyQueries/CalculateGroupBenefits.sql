

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



select OwnerName , b.TradingDate , n.Namad , RealCost , nh.PayaniGheymat , 
case when b.CountOfPortion-bshStatus.ShopCount = 0 then '0'
	 when b.CountOfPortion-bshStatus.ShopCount > 0 then   REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,(nh.PayaniGheymat * (b.CountOfPortion-bshStatus.ShopCount) - b.RealCost*(b.CountOfPortion-bshStatus.ShopCount) )),1), '.00','')
	 when bshStatus.ShopCount is null then REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,(nh.PayaniGheymat - b.RealCost) * (b.CountOfPortion)),1), '.00','') end 'مبلغ‌س/ز‌خالص' ,
	 case when bshStatus.ShopCount is not null then  case when b.CountOfPortion-bshStatus.ShopCount > 0 then  REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,b.RealCost*(b.CountOfPortion-bshStatus.ShopCount)),1), '.00','') 
	when b.CountOfPortion-bshStatus.ShopCount = 0 then '0'  end  
	  when bshStatus.ShopCount is null then REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,b.RealCost*(b.CountOfPortion)),1), '.00','') end 'ق.تمام‌شده‌خ.کل‌سهام',
	  case when bshStatus.ShopCount is not null then b.CountOfPortion-bshStatus.ShopCount when bshStatus.ShopCount is null then b.CountOfPortion end 'ت.سهم‌باقی.‌پس‌از‌ف.'
from Basket  b
inner join Namad n on n.Namad = b.Namad
inner join (select max(id) maxID , NamadId from NamadHistory group by NamadId) nhStatus on nhStatus.NamadId = n.ID
inner join NamadHistory nh on nh.ID = nhStatus.maxID
left outer join (select BasketID , sum(ShopCount) ShopCount , AVG(ShoppingCost) ShopAvgCost from BasketShopping group by BasketID) bshStatus on bshStatus.BasketID = b.id 
order by b.TradingDate

-- select minimum date of trading
select min(trading.TradingDate) from (
select OwnerName , b.TradingDate , n.Namad , RealCost , nh.PayaniGheymat , 
	 case when bshStatus.ShopCount is not null then  
		case when b.CountOfPortion-bshStatus.ShopCount > 0 then  b.RealCost*(b.CountOfPortion-bshStatus.ShopCount) 
		when b.CountOfPortion-bshStatus.ShopCount = 0 then 0  end  
	 when bshStatus.ShopCount is null then b.RealCost*(b.CountOfPortion) end TotalMoney
from Basket  b
inner join Namad n on n.Namad = b.Namad
inner join (select max(id) maxID , NamadId from NamadHistory group by NamadId) nhStatus on nhStatus.NamadId = n.ID
inner join NamadHistory nh on nh.ID = nhStatus.maxID
left outer join (select BasketID , sum(ShopCount) ShopCount , AVG(ShoppingCost) ShopAvgCost from BasketShopping group by BasketID) bshStatus on bshStatus.BasketID = b.id ) as trading
where trading.TotalMoney > 0


select pay.OwnerName , pay.paymentdat , (select count(distinct tradingdate) from NamadHistory where TradingDate >= pay.PaymentDat) 
 from (select p.ownername , min(p.PaymentDate) paymentdat 
from Payments p group by p.OwnerName) as pay

--- محاسبه میانگین روزهای پرداخت پول
select duration.OwnerName, avg(duration.dys) from 
(select  ownerPay.tdate ,  ownerPay.OwnerName , (select count(distinct tradingdate) from NamadHistory where TradingDate >= ownerPay.tdate) dys
from 
(select pay.OwnerName, pay.tdate
from 
(select p.OwnerName , p.PaymentDate tdate , N'پرداخت' ttype from Payments p group by p.OwnerName , p.PaymentDate)
pay group by pay.OwnerName , pay.tdate) ownerPay
inner join 
(select p.PaymentDate tdate , N'پرداخت' ttype from Payments p group by  p.PaymentDate) totalPay
on ownerPay.tdate = totalPay.tdate) as duration
group by duration.OwnerName

select calc4.* , round( cast(calc4.divisionOnDays as float)/cast(calc4.totalDivisionOnDys as float) , 3) percentOfRemaindMoney , totalBenefit.TotalBenefit
, round((cast(calc4.divisionOnDays as float)/cast(calc4.totalDivisionOnDys as float) )* totalBenefit.TotalBenefit , 3) FinalOwnerBenefit
 from (
select calculateOwnerPortion.OwnerName , calculateOwnerPortion.OwnerPayments, calculateOwnerPortion.tradingDuration , calculateOwnerPortion.totalDays 
, calculateOwnerPortion.totalPayment , ((calculateOwnerPortion.OwnerPayments/calculateOwnerPortion.totalDays)*calculateOwnerPortion.tradingDuration) divisionOnDays 
,(select 
sum(((calculateOwnerPortion.OwnerPayments/calculateOwnerPortion.totalDays)*calculateOwnerPortion.tradingDuration)) divisionOnDays 
 from (
select pay.OwnerName , pay.OwnerPayments , pay.totalPayment  , cast(pay.OwnerPayments as float)/cast(pay.totalPayment as float) divisionOnMoney 
, paym.paymentdat , paym.tradingDuration 
, (select sum (days.tradingDuration) from (
select  (select count(distinct tradingdate) days from NamadHistory where TradingDate >= pay.PaymentDat) tradingDuration
 from (select p.ownername , min(p.PaymentDate) paymentdat 
from Payments p where p.OwnerName in (select Name from BasketOwner where GroupId = 1)  group by p.OwnerName) as pay) as days) totalDays
from (
select p.OwnerName , sum(p.Amount) OwnerPayments , (select sum(amount) from Payments where p.OwnerName in (select Name from BasketOwner where GroupId = 1)) totalPayment from Payments p  where p.OwnerName in (select ownername from BasketOwner where GroupId = 1) group by p.OwnerName) as pay
inner join 
(select pay.OwnerName , pay.paymentdat , (select count(distinct tradingdate)  from NamadHistory where TradingDate >= pay.PaymentDat) tradingDuration
 from (select p.ownername , min(p.PaymentDate) paymentdat 
from Payments p where p.OwnerName in (select Name from BasketOwner where GroupId = 1) group by p.OwnerName) as pay) as paym on pay.OwnerName = paym.OwnerName) as calculateOwnerPortion) totalDivisionOnDys
 from (
select pay.OwnerName , pay.OwnerPayments , pay.totalPayment  , cast(pay.OwnerPayments as float)/cast(pay.totalPayment as float) divisionOnMoney 
, paym.paymentdat , paym.tradingDuration 
, (select sum (days.tradingDuration) from (
select  (select count(distinct tradingdate) days from NamadHistory where TradingDate >= pay.PaymentDat) tradingDuration
 from (select p.ownername , min(p.PaymentDate) paymentdat 
from Payments p where p.OwnerName in (select Name from BasketOwner where GroupId = 1) group by p.OwnerName) as pay) as days) totalDays
from (
select p.OwnerName , sum(p.Amount) OwnerPayments , (select sum(amount) from Payments where OwnerName in (select Name from BasketOwner where GroupId = 1)) totalPayment from Payments p where p.OwnerName in (select ownername from BasketOwner where GroupId = 1) group by p.OwnerName) as pay
inner join 
(select pay.OwnerName , pay.paymentdat , (select count(distinct tradingdate)  from NamadHistory where TradingDate >= pay.PaymentDat) tradingDuration
 from (select p.ownername , min(p.PaymentDate) paymentdat 
from Payments p where p.OwnerName in (select Name from BasketOwner where GroupId = 1) group by p.OwnerName) as pay) as paym on pay.OwnerName = paym.OwnerName) as calculateOwnerPortion) as calc4
,
(select sum(TotalMoney.TotalMoney)-sum(totalPeyment.totalPayment) TotalBenefit from 
(select bsk.OwnerName  , (select sum(amount)
from Payments where OwnerName = bsk.OwnerName) totalPayment from
(select ownername , sum(CountOfPortion*RealCost*-1) cost , N'خرید' ttype from basket where GroupId = 1 group by OwnerName 
union
select b.OwnerName , sum(ShopCount*ShoppingCost) cost , N'فروش' ttype from BasketShopping bs inner join Basket b on b.id = bs.BasketID where b.GroupId = 1 group by b.OwnerName  
union
select p.OwnerName , sum(Amount) cost , N'پرداخت' ttype from Payments p where p.OwnerName in (select Name from BasketOwner where GroupId = 1) group by p.OwnerName 
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
group by totalMoney.OwnerName) as TotalMoney on TotalMoney.OwnerName = totalPeyment.OwnerName) as totalBenefit;

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
case when tWithdrawMoney.OwnerWithdraw is null then 0 when tWithdrawMoney.OwnerWithdraw is not null then tWithdrawMoney.OwnerWithdraw end ,
tMoney.TotalRealCost , tMoney.TotalMoney , tPaymentDuration.avgDays 
, round( (( cast( tPayments.OwnerPayment as float)/@TotalDays)*tPaymentDuration.avgDays) /@SumOfDivisionOnDays , 5) divisionOnAvgDays ,
case when tWithdrawMoney.OwnerWithdraw is null then round( (((cast( tPayments.OwnerPayment as float)/@TotalDays)*tPaymentDuration.avgDays) /@SumOfDivisionOnDays) * @TotalBenefit , 5)
	when tWithdrawMoney.OwnerWithdraw is not null then round( (((cast( tPayments.OwnerPayment as float)/@TotalDays)*tPaymentDuration.avgDays) /@SumOfDivisionOnDays) * @TotalBenefit , 5) + tWithdrawMoney.OwnerWithdraw  end 

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
	where p.TransactionType=N'برداشت' and p.OwnerName in (select Name from BasketOwner where GroupId = @GroupId) group by p.OwnerName ) tWithdrawMoney on tMoney.OwnerName = tWithdrawMoney.OwnerName

where tPayments.OwnerName = tPaymentDuration.OwnerName and tMoney.OwnerName = tPayments.OwnerName ;


--01
select tPayments.OwnerName , tPayments.OwnerPayment,tMoney.TotalRealCost , tMoney.TotalMoney , tPaymentDuration.avgDays 
, round( (( cast( tPayments.OwnerPayment as float)/@TotalDays)*tPaymentDuration.avgDays) /@SumOfDivisionOnDays , 5) divisionOnAvgDays ,
round( (((cast( tPayments.OwnerPayment as float)/@TotalDays)*tPaymentDuration.avgDays) /@SumOfDivisionOnDays) * @TotalBenefit , 5)
 from 
(select duration.OwnerName, avg(duration.dys) avgDays from 
(select  ownerPay.tdate ,  ownerPay.OwnerName , (select count(distinct tradingdate) from NamadHistory where TradingDate >= ownerPay.tdate) dys
from (select p.OwnerName , p.PaymentDate tdate from Payments p) ownerPay) as duration  
group by duration.OwnerName) as tPaymentDuration,
(select p.OwnerName , sum(Amount) OwnerPayment  from Payments p where p.OwnerName in (select Name from BasketOwner where GroupId = 1) group by p.OwnerName ) tPayments,
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
left outer join (select BasketID , sum(ShopCount) ShopCount , AVG(ShoppingCost) ShopAvgCost from BasketShopping group by BasketID) bshStatus on bshStatus.BasketID = b.id where b.GroupId = 1 ) as totalMoney
group by totalMoney.OwnerName) tMoney
where tPayments.OwnerName = tPaymentDuration.OwnerName and tMoney.OwnerName = tPayments.OwnerName




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


---- for compare 
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
left outer join (select BasketID , sum(ShopCount) ShopCount , AVG(ShoppingCost) ShopAvgCost from BasketShopping group by BasketID) bshStatus on bshStatus.BasketID = b.id
where b.GroupId = 1 ) as totalMoney
group by totalMoney.OwnerName

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
