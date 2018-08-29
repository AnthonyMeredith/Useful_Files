using System;
using System.Linq;
using System.Text;
using System.Data;
using System.Collections.Generic;

namespace Art.Rest.v1.Test
{
    public class ClientOrderDetail
	{
        public string Href { get; set; }
        public ClientOrder Order { get; set; }
        public ClientProduct Product { get; set; }
        public double Price { get; set; }
        public int Quantity { get; set; }
	} 
}	
