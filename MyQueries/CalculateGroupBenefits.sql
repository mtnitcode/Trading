
select bsk.OwnerName 'گردش مالی' , (select REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,sum(amount)),1), '.00','') from Payments where OwnerName = bsk.OwnerName and PaymentDate <= bsk.tdate) 'مجموع پرداخت/دریافت' , bsk.tdate 'تاریخ ' 
, REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,bsk.cost),1), '.00','') 'مبلغ خرید/فروش', bsk.ttype 'نوع گردش مالی' from
(select ownername , tradingdate tdate , sum(CountOfPortion*RealCost*-1) cost , N'خرید' ttype from basket group by OwnerName , TradingDate
union
select b.OwnerName , shoppingdate tdate , sum(ShopCount*ShoppingCost) cost , N'فروش' ttype from BasketShopping bs inner join Basket b on b.id = bs.BasketID group by b.OwnerName , ShoppingDate
union
select p.OwnerName , p.PaymentDate tdate , sum(Amount) cost , N'پرداخت' ttype from Payments p group by p.OwnerName , p.PaymentDate
) bsk
order by bsk.OwnerName , bsk.tdate

select  ownerPay.tdate ,  ownerPay.OwnerName , ownerPay.amount, totalPay.paymentSum  ,  cast(ownerPay.amount as float)/cast( totalPay.paymentSum as float) from 
(
select pay.OwnerName, pay.tdate, (select sum(amount) from Payments where OwnerName = pay.OwnerName and PaymentDate <=pay.tdate) amount from 
(select p.OwnerName , p.PaymentDate tdate , sum(Amount) amount , N'پرداخت' ttype from Payments p group by p.OwnerName , p.PaymentDate)
pay group by pay.OwnerName , pay.tdate) ownerPay
inner join 
(select p.PaymentDate tdate , (select sum (amount) from Payments where PaymentDate <= p.PaymentDate) paymentSum , N'پرداخت' ttype from Payments p group by  p.PaymentDate) totalPay
on ownerPay.tdate = totalPay.tdate
order by ownerPay.OwnerName , ownerPay.tdate

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


-- محاسبه سود روزانه
select basketHistory.historyDate , sum(basketHistory.PayaniDarsad) from (
select b.TradingDate basketDate , nh.TradingDate historyDate,b.Namad , n.ID namadid ,  nh.PayaniDarsad , b.GroupId
, case when bshStatus.ShopCount is not null then b.CountOfPortion-bshStatus.ShopCount when bshStatus.ShopCount is null then b.CountOfPortion end countOfPortion
from NamadHistory nh inner join Namad n on n.ID = nh.NamadId
inner join Basket b on b.Namad = n.Namad 
left outer join (select BasketID , sum(ShopCount) ShopCount , AVG(ShoppingCost) ShopAvgCost from BasketShopping group by BasketID) bshStatus on bshStatus.BasketID = b.id
where nh.TradingDate > b.TradingDate ) as basketHistory
where basketHistory.countOfPortion >0 and basketHistory.GroupId is not null
group by basketHistory.historyDate
order by basketHistory.historyDate



-- daily benefit with names and total inversments
select baskethistory.* , basketOwners.Name 
from (
select basketHistory.historyDate , sum(basketHistory.PayaniDarsad) payaniDarsad , (select sum(amount) from Payments where PaymentDate <=basketHistory.historyDate) amount from (
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

-- daily benefit with names and total inversments
select * , bskOwners.amount*bskOwners.avgPayaniDarsad*0.01 totalBenefitInDay,  cast(bskOwners.OwnerAmount as float)/cast( bskOwners.amount as float) invPercent ,
 round( (bskOwners.amount*bskOwners.avgPayaniDarsad*0.01) *  (cast(bskOwners.OwnerAmount as float)/cast( bskOwners.amount as float)) , 3) personalBenefitInDay from (
select baskethistory.* , basketOwners.Name ,  (select sum(amount) from Payments where PaymentDate <=basketHistory.historyDate and OwnerName = basketOwners.Name) OwnerAmount 
from (
select basketHistory.historyDate , sum(basketHistory.PayaniDarsad) avgPayaniDarsad , (select sum(amount) from Payments where PaymentDate <=basketHistory.historyDate) amount 
from (
select b.TradingDate basketDate , nh.TradingDate historyDate,b.Namad , n.ID namadid ,  nh.PayaniDarsad , b.GroupId
, case when bshStatus.ShopCount is not null then b.CountOfPortion-bshStatus.ShopCount when bshStatus.ShopCount is null then b.CountOfPortion end countOfPortion
from NamadHistory nh inner join Namad n on n.ID = nh.NamadId
inner join Basket b on b.Namad = n.Namad 
left outer join (select BasketID , sum(ShopCount) ShopCount , AVG(ShoppingCost) ShopAvgCost from BasketShopping group by BasketID) bshStatus on bshStatus.BasketID = b.id
where nh.TradingDate > b.TradingDate ) as basketHistory
where basketHistory.countOfPortion > 0 and basketHistory.GroupId is not null
group by basketHistory.historyDate) as baskethistory
, (select name from BasketOwner) basketOwners) as bskOwners where bskOwners.OwnerAmount is not null
order by bskOwners.Name , bskOwners.historyDate




select replace(REPLACE(dbo.GregorianToPersian(CONVERT (date, SYSDATETIMEOFFSET()) ),'-','/') , '/' ,'-') 'تاریخ گزارش', b.id 'کد خرید', b.OwnerName 'صاحب سهم', nmd.Name 'نام کامل' , nmd.namad  'نام نماد' ,
b.TradingDate 'تاریخ‌خرید' , b.CountOfPortion 'ت.سهم‌خریداری‌شده'
,case when bshStatus.ShopCount is not null then b.CountOfPortion-bshStatus.ShopCount when bshStatus.ShopCount is null then b.CountOfPortion end 'ت.سهم‌باقی.‌پس‌از‌ف.'
, REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,b.AvverageCost),1), '.00','') 'ق.خالص‌خ.‌یک‌سهم', REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,b.RealCost),1), '.00','') 'ق.تمام‌شده‌خرید1سهم'
,case when bshStatus.ShopCount is not null then  case when b.CountOfPortion-bshStatus.ShopCount > 0 then  REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,b.RealCost*(b.CountOfPortion-bshStatus.ShopCount)),1), '.00','') 
	when b.CountOfPortion-bshStatus.ShopCount = 0 then  REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,b.RealCost*(b.CountOfPortion)),1), '.00','')  end  
	  when bshStatus.ShopCount is null then REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,b.RealCost*(b.CountOfPortion)),1), '.00','') end 'ق.تمام‌شده‌خ.کل‌سهام'
, REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,nh.PayaniGheymat),1), '.00','') 'ق.روز‌سهم' ,
case when b.CountOfPortion-bshStatus.ShopCount = 0 then REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,(nh.PayaniGheymat*b.CountOfPortion - b.RealCost * (b.CountOfPortion) )),1), '.00','') 
	 when b.CountOfPortion-bshStatus.ShopCount > 0 then   REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,(nh.PayaniGheymat * (b.CountOfPortion-bshStatus.ShopCount) - b.RealCost*(b.CountOfPortion-bshStatus.ShopCount) )),1), '.00','')
	 when bshStatus.ShopCount is null then REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,(nh.PayaniGheymat - b.RealCost) * (b.CountOfPortion)),1), '.00','') end 'مبلغ‌س/ز‌خالص' ,
case when bshStatus.ShopCount is not null then (ROUND( (convert(float, nh.PayaniGheymat) / b.RealCost)-1 , 5 ))*100 
	 when bshStatus.ShopCount is null then (ROUND( (convert(float, nh.PayaniGheymat) / b.RealCost)-1 , 5 ))*100 end 'درصد‌س/ز‌خالص'  , 
case when bshStatus.ShopCount is not null then REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,nh.PayaniGheymat * (b.CountOfPortion-bshStatus.ShopCount)),1), '.00','') 
	 when bshStatus.ShopCount is null then REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,nh.PayaniGheymat * (b.CountOfPortion)),1), '.00','') end 'کل‌سرمایه‌باحتساب‌س/ز' 
, b.FirstOffer 'عرضه‌اولیه' ,
REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,nh.ShopHajm),1), '.00','') 'حجم‌ف.درروزآخر' , REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,nh.BuyHajm),1), '.00','') 'حجم‌خ.درروزآخر'
from Namad nmd
inner join Basket b on b.Namad = nmd.Namad
inner join (select max(id) maxID , NamadId from NamadHistory group by NamadId) nhStatus on nhStatus.NamadId = nmd.ID
left outer join (select BasketID , sum(ShopCount) ShopCount , AVG(ShoppingCost) ShopAvgCost from BasketShopping group by BasketID) bshStatus on bshStatus.BasketID = b.id
inner join NamadHistory nh on nh.ID = nhStatus.maxID
--where nmd.Namad = N'وغدير'
order by b.OwnerName , b.TradingDate;


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