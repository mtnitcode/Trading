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
    
    public partial class Payment
    {
        public string PaymentDate { get; set; }
        public Nullable<long> Amount { get; set; }
        public string OwnerName { get; set; }
        public long id { get; set; }
        public string Description { get; set; }
        public string BrokerName { get; set; }
        public string TransactionType { get; set; }
        public Nullable<long> OwnerId { get; set; }
    
        public virtual BasketOwner BasketOwner { get; set; }
    }
}
