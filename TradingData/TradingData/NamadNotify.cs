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
    
    public partial class NamadNotify
    {
        public Nullable<long> tseID { get; set; }
        public string AnnounceDate { get; set; }
        public string Title { get; set; }
        public long Id { get; set; }
        public long NamadId { get; set; }
    
        public virtual Namad Namad { get; set; }
    }
}
