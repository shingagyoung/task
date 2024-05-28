using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace DicomServer.Models
{
    public struct Study
    {
        public int id { get; }
        public string studyInstanceUID { get; }
        public string studyID { get; }
        public string studyDateTime { get; }
        public string studyDescription { get; }
        public string patientID { get; }
        public string patientName { get; }
        public string patientBirthDate { get; }
        public string patientSex { get; }
        public string ? referringPhysicianName { get; }
        public int numberOfSeries { get; }
        public string createdDateTime { get; }
        public string lastModifiedDateTime { get; }
        public string ? tag { get; }
        public string ? memo { get; }

    }
}