using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using DicomServer.Models;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ApiExplorer;

namespace DicomServer.DTO
{
    class StudyDB
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