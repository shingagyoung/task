using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using DicomServer.Domain;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ApiExplorer;
using Microsoft.OpenApi.Extensions;
using Microsoft.VisualBasic;

namespace DicomServer.Service
{
    public class StudyService
    {

        private List<Study> _studies;

        public StudyService(List<Study> studies) {
            _studies = studies;
        }

        public List<Study> GetStudies(
            [FromQuery(Name = "filter")] string? filter,
            [FromQuery(Name = "beginDate")] DateTime? beginDate,
            [FromQuery(Name = "endDate")] DateTime? endDate,
            [FromQuery(Name = "extFilter")] bool? extFilter
            ) {
            
            List<Study> filtered = _studies;

            if (filter != null) {
                filtered = filtered
                .FindAll(study =>
                    study.patientName.Contains(filter, StringComparison.OrdinalIgnoreCase) ||
                    study.patientID.Contains(filter, StringComparison.OrdinalIgnoreCase) ||
                    (extFilter == true && study.studyDescription.Contains(filter, StringComparison.OrdinalIgnoreCase)) ||
                    (extFilter == true && study.memo != null && study.memo.Contains(filter, StringComparison.OrdinalIgnoreCase))
                );
            }

            if (beginDate != null) {
                filtered = filtered
                .FindAll(study => study.createdDateTime.Equals(beginDate));
            }
            if (endDate != null) {
                filtered = filtered
                .FindAll(study => study.lastModifiedDateTime.Equals(endDate));
            }
            
            return filtered;
        }
    }
}
