using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using DicomServer.Domain;
using Microsoft.AspNetCore.Mvc;

namespace DicomServer.Service
{
    public class SeriesService
    {

        private List<Series> _series;

        public SeriesService(List<Series> series) {
            _series = series;
        }

        public List<Series> GetSeries(
            [FromQuery(Name = "studyId")] long? id
            ) {
            return _series.FindAll(series => series.dicomStudyId == id);
        }

    }
}