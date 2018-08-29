using System;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Management.Compute.Fluent;
using Microsoft.Azure.Management.Compute.Fluent.Models;
using Microsoft.Azure.Management.Fluent;
using Microsoft.Azure.Management.ResourceManager.Fluent;
using Microsoft.Azure.Management.ResourceManager.Fluent.Core;
using Microsoft.Extensions.Configuration;

// For more information on enabling MVC for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace CiCdTraining.Controllers
{
    public class FormController : Controller
    {
        // 
        // GET: /Form/

        public IActionResult Index()
        {
            return View();
        }

        // 
        // GET: /Form/Home/ 

        //[HttpGet]
        public IActionResult Home()
        {
            return View();
        }

        public IActionResult ProcessForm()
        {
            string NumberOfVMs = HttpContext.Request.Form["NumberOfVMs"];
            string VMpassword = HttpContext.Request.Form["VMpassword"];
            string ExpiryDate = HttpContext.Request.Form["ExpiryDate"];
            string EmailAddress = HttpContext.Request.Form["EmailAddress"];

            var credentials = SdkContext.AzureCredentialsFactory.FromFile("azureauth.properties");
            var azure = Azure
                .Configure()
                .WithLogLevel(HttpLoggingDelegatingHandler.Level.Basic)
                .Authenticate(credentials)
                .WithDefaultSubscription();

            var groupName = "techtestRg";
            var location = Region.EuropeWest;

            var resourceGroup = azure.ResourceGroups.Define(groupName)
                .WithRegion(location)
                .Create();
            
            var availabilitySet = azure.AvailabilitySets.Define("techtestAVSet")
                .WithRegion(location)
                .WithExistingResourceGroup(groupName)
                .WithSku(AvailabilitySetSkuTypes.Managed)
                .Create();
            
            var publicIPAddress = azure.PublicIPAddresses.Define("techtestPublicIP")
                .WithRegion(location)
                .WithExistingResourceGroup(groupName)
                .WithDynamicIP()
                .Create();
            
            var network = azure.Networks.Define("techtestVNet")
                .WithRegion(location)
                .WithExistingResourceGroup(groupName)
                .WithAddressSpace("10.0.0.0/16")
                .WithSubnet("techtestSubnet", "10.0.0.0/24")
                .Create();

            var networkInterface = azure.NetworkInterfaces.Define("techtestNIC")
                .WithRegion(location)
                .WithExistingResourceGroup(groupName)
                .WithExistingPrimaryNetwork(network)
                .WithSubnet("techtestSubnet")
                .WithPrimaryPrivateIPAddressDynamic()
                .WithExistingPrimaryPublicIPAddress(publicIPAddress)
                .Create();
            
            for (int i = 1; i < Convert.ToInt32(NumberOfVMs) + 1; i++)
            {
                IVirtualMachine windowsVM = azure.VirtualMachines.Define("techtest" + i)
                    .WithRegion(Region.EuropeWest)
                    .WithExistingResourceGroup(groupName)
                    .WithExistingPrimaryNetworkInterface(networkInterface)
                    .WithWindowsCustomImage(Program.Configuration["CustomImage"])
                    .WithAdminUsername("techtest")
                    .WithAdminPassword(VMpassword)
                    .WithComputerName("techtest" + i)
                    .WithExistingAvailabilitySet(availabilitySet)
                    .WithSize(Microsoft.Azure.Management.Compute.Models.VirtualMachineSizeTypes.StandardD3V2)
                    .WithTag("date", ExpiryDate)
                    .Create();
                var vm = azure.VirtualMachines.GetByResourceGroup(groupName, "techtest" + i);
                vm.PowerOff();
            }

            ViewBag.Message = $"Query String {NumberOfVMs}, {VMpassword}, {ExpiryDate}, {EmailAddress} !";
            return View("Message");
        }

        //[HttpPost]
        //public IActionResult Home(int NumberOfVMs, string VMpassword, string ExpiryDate, string EmailAddress)
        //{
        //    return Content($"Number of VM's: {NumberOfVMs}, VM Password: {VMpassword}, VM expiry date: {ExpiryDate}, User email address: {EmailAddress}");
        //}

        public IActionResult Message()
        {
            return View();
        }

    }
}