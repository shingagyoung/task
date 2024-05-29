using DicomServer.Controller;
using DicomServer.Service;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.ObjectPool;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(option => {
    option.SwaggerDoc("v1", new OpenApiInfo { Title = "DICOM API", Description = "DICOM 정보 제공을 위한 서버", Version = "v1"});
});

var app = builder.Build();
app.UseSwagger();
app.UseSwaggerUI( option => {
    option.SwaggerEndpoint("/swagger/v1/swagger.json", "DICOM API V1");
});


StudyService study = new StudyService {};
SeriesService series = new SeriesService {};


DicomController controller = new DicomController(builder.Environment);
controller.GetFile("study.json");

app.MapGet("/Dicom/Series", ([FromQuery(Name = "studyId")] long? id) => series.GetSeries(id));
app.MapGet("/Dicom/Study", (
    [FromQuery(Name = "filter")] string? filter,
    [FromQuery(Name = "beginDate")] DateTime? beginDate,
    [FromQuery(Name = "endDate")] DateTime? endDate,
    [FromQuery(Name = "extFilter")] bool? extFilter) => study.GetStudies(filter, beginDate, endDate, extFilter));

app.Run();
