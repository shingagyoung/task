using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace DicomServer.Domain
{
    public struct Study
    {
        public int id { get; set; }
        public string studyInstanceUID { get; set; }
        public string studyID { get; set; }
        public string studyDateTime { get; set; }
        public string studyDescription { get; set; }
        public string patientID { get; set; }
        public string patientName { get; set; }
        public string patientBirthDate { get; set; }
        public string patientSex { get; set; }
        public string ? referringPhysicianName { get; set; }
        public int numberOfSeries { get; set; }
        public string createdDateTime { get; set; }
        public string lastModifiedDateTime { get; set; }
        public string ? tag { get; set; }
        public string ? memo { get; set; }

    }
}