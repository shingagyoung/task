using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace DicomServer.Models
{
    public struct Study
    {
        int id { get; }
        string studyInstanceUID { get; }
        string studyID { get; }
        string studyDateTime { get; }
        string studyDescription { get; }
        string patientID { get; }
        string patientName { get; }
        string patientBirthDate { get; }
        string patientSex { get; }
        string ? referringPhysicianName { get; }
        int numberOfSeries { get; }
        string createdDateTime { get; }
        string lastModifiedDateTime { get; }
        string ? tag { get; }
        string ? memo { get; }

    }
}