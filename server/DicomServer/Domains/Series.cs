using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace DicomServer.Domain
{
    public struct Series 
    {
        
        public int id { get; set; }
        public int dicomStudyId { get; set; }
        public string seriesInstanceUID { get; set; }
        public string seriesNumber { get; set; }
        public string modality { get; set; }
        public string seriesDateTime { get; set; }
        public string patientPosition { get; set; }
        public string acquisitionNumber { get; set; }
        public string ? scanningSequence { get; set; }
        public string bodyPartExamined { get; set; }
        public string seriesDescription { get; set; }
        public string rows { get; set; }
        public string columns { get; set; }
        public string pixelSpacing { get; set; }
        public string sliceThickness { get; set; }
        public string imageType { get; set; }
        public string imageOrientationPatient { get; set; }
        public int numberOfDicomFiles { get; set; }
        public string createdDateTime { get; set; }
        public string lastModifiedDateTime { get; set; }
        public string volumeFilePath { get; set; }
        public string ? tag { get; set; }
        public string ? memo { get; set; }
    }
}