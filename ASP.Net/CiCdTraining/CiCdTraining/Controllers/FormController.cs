using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;

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