using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using DicomServer.Models;
using Microsoft.AspNetCore.Mvc;

namespace DicomServer.DTO
{
    class SeriesDB
    {
        private List<Series> _series = new List<Series>() {

        };

        public List<Series> GetSeries([FromQuery(Name = "studyId")] long? id) {
            return _series.FindAll(series => series.id == id);
        }

    }
}