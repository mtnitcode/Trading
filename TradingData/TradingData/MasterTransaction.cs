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
    
    public partial class MasterTransaction
    {
        public long Id { get; set; }
        public string ActivityType { get; set; }
        public string Description { get; set; }
        public string ActivityDate { get; set; }
        public Nullable<long> Debtor { get; set; }
        public Nullable<long> Creditor { get; set; }
        public Nullable<long> Remaind { get; set; }
        public string BrokerName { get; set; }
        public string OwnerName { get; set; }
    }
}
