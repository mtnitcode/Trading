//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace TradingData
{
    using System;
    using System.Collections.Generic;
    
    public partial class NamadHistory
    {
        public long ID { get; set; }
        public string TradingDate { get; set; }
        public long NamadId { get; set; }
        public long Tedad { get; set; }
        public long Hajm { get; set; }
        public long Arzesh { get; set; }
        public long Dirooz { get; set; }
        public long AvvalinGheymat { get; set; }
        public long AkharinGheymat { get; set; }
        public long KamtarinGheymat { get; set; }
        public long BishtarinGheymat { get; set; }
        public long PayaniGheymat { get; set; }
        public Nullable<long> AkharinTaghyeer { get; set; }
        public Nullable<double> AkharinDarsad { get; set; }
        public Nullable<long> PayaniTaghyeer { get; set; }
        public Nullable<double> PayaniDarsad { get; set; }
        public Nullable<int> BuyTedad { get; set; }
        public Nullable<int> ShopTedad { get; set; }
        public Nullable<long> BuyHajm { get; set; }
        public Nullable<long> ShopHajm { get; set; }
        public Nullable<long> BuyCost { get; set; }
        public Nullable<long> ShopCost { get; set; }
    
        public virtual Namad Namad { get; set; }
    }
}
