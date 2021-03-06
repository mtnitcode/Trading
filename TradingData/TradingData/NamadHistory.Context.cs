﻿//------------------------------------------------------------------------------
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
    using System.Data.Entity;
    using System.Data.Entity.Infrastructure;
    using System.Data.Entity.Core.Objects;
    using System.Linq;
    
    public partial class TradingContext : DbContext
    {
        public TradingContext()
            : base("name=TradingEntities")
        {
        }
    
        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            throw new UnintentionalCodeFirstException();
        }
    
        public virtual DbSet<NamadHistory> NamadHistories { get; set; }
        public virtual DbSet<Namad> Namads { get; set; }
        public virtual DbSet<Industry> Industries { get; set; }
        public virtual DbSet<NamadNotify> NamadNotifies { get; set; }
        public virtual DbSet<Basket> Baskets { get; set; }
        public virtual DbSet<Payment> Payments { get; set; }
        public virtual DbSet<BasketShopping> BasketShoppings { get; set; }
        public virtual DbSet<MasterTransaction> MasterTransactions { get; set; }
        public virtual DbSet<BasketGroup> BasketGroups { get; set; }
        public virtual DbSet<BasketOwner> BasketOwners { get; set; }
    
        public virtual ObjectResult<procCalculateMemberBenefits_Result> procCalculateMemberBenefits(Nullable<int> groupId)
        {
            var groupIdParameter = groupId.HasValue ?
                new ObjectParameter("GroupId", groupId) :
                new ObjectParameter("GroupId", typeof(int));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<procCalculateMemberBenefits_Result>("procCalculateMemberBenefits", groupIdParameter);
        }
    }
}
