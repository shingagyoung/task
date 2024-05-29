using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;

namespace DicomServer.Controller
{
    [ApiController]
    [Route("api/[controller]")]
    public class DicomController : ControllerBase
    {
        private readonly IWebHostEnvironment _env;
    public DicomController(IWebHostEnvironment env) {
        _env = env;
    }

public IActionResult GetFile(string filename) 
    {
        string path = Path.Combine(_env.ContentRootPath, "Resources", filename);
        string jsonString = System.IO.File.ReadAllText(path);

        return Content(jsonString);
    }

    }
}