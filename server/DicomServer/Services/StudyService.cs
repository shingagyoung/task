using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using DicomServer.Domain;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ApiExplorer;
using Microsoft.VisualBasic;

namespace DicomServer.Service
{
    class StudyService
    {

        private List<Study> _study = new List<Study>() {

        };

        public List<Study> GetStudies(
            [FromQuery(Name = "filter")] string? filter,
            [FromQuery(Name = "beginDate")] DateTime? beginDate,
            [FromQuery(Name = "endDate")] DateTime? endDate,
            [FromQuery(Name = "extFilter")] bool? extFilter
            ) {
            return _study;
        }
    }
}
