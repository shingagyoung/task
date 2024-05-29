using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace DicomServer.Domain
{
    public struct Series 
    {
        
        public int id { get; }
        public int dicomStudyId { get; }
        public string seriesInstanceUID { get; }
        public string seriesNumber { get; }
        public string modality { get; }
        public string seriesDateTime { get; }
        public string patientPosition { get; }
        public string acquisitionNumber { get; }
        public string ? scanningSequence { get; }
        public string bodyPartExamined { get; }
        public string seriesDescription { get; }
        public string rows { get; }
        public string columns { get; }
        public string pixelSpacing { get; }
        public string sliceThickness { get; }
        public string imageType { get; }
        public string imageOrientationPatient { get; }
        public int numberOfDicomFiles { get; }
        public string createdDateTime { get; }
        public string lastModifiedDateTime { get; }
        public string volumeFilePath { get; }
        public string ? tag { get; }
        public string ? memo { get; }
    }
}