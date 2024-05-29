using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using DicomServer.Domain;
using DicomServer.Service;
using Microsoft.AspNetCore.Cors;
using Microsoft.AspNetCore.Mvc;

namespace DicomServer.Controller
{
    [ApiController]
    [Route("[controller]")]
    [EnableCors("AllowSpecificOrigin")]
    public class DicomController : ControllerBase
    {
        private readonly IWebHostEnvironment _env;
        private readonly StudyService _studyService;
        private readonly SeriesService _seriesService;
        public DicomController(IWebHostEnvironment env, StudyService studyService, SeriesService seriesService) {
            _env = env;
            _studyService = studyService;
            _seriesService = seriesService;
        }

        [HttpGet]
        [Route("Series")]
        public ActionResult<List<Series>> GetSeries(long? id)
        {
            var series = _seriesService.GetSeries(id);

            if (series is null)
            {
                return NotFound();
            }

            return series;
        }

        [HttpGet]
        [Route("Study")]
        public ActionResult<List<Study>> GetStudies(
            string? filter,
            DateTime? beginDate,
            DateTime? endDate,
            bool? extFilter
            )
        {
            var studies = _studyService.GetStudies(filter, beginDate, endDate, extFilter);

            if (studies is null)
            {
                return NotFound();
            }

            return studies;
        }

        private IActionResult GetFile(string filename) 
        {
            string path = Path.Combine(_env.ContentRootPath, "Resources", filename);
            string jsonString = System.IO.File.ReadAllText(path);

            return Content(jsonString);
        }

    }
}
