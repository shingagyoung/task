using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace DicomServer.Models
{
    struct Series 
    {
        int id { get; }
        int dicomStudyId { get; }
        string seriesInstanceUID { get; }
        string seriesNumber { get; }
        string modality { get; }
        string seriesDateTime { get; }
        string patientPosition { get; }
        string acquisitionNumber { get; }
        string ? scanningSequence { get; }
        string bodyPartExamined { get; }
        string seriesDescription { get; }
        string rows { get; }
        string columns { get; }
        string pixelSpacing { get; }
        string sliceThickness { get; }
        string imageType { get; }
        string imageOrientationPatient { get; }
        int numberOfDicomFiles { get; }
        string createdDateTime { get; }
        string lastModifiedDateTime { get; }
        string volumeFilePath { get; }
        string ? tag { get; }
        string ? memo { get; }
    }
}