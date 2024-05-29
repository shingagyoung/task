using System.Text.Json;
using DicomServer.Controller;
using DicomServer.Domain;
using DicomServer.Service;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.ObjectPool;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

// Make Swagger.
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(option => {
    option.SwaggerDoc("v1", new OpenApiInfo { Title = "DICOM API", Description = "DICOM 정보 제공을 위한 서버", Version = "v1"});
});

// Read json files.
string seriesFile = Path.Combine(Directory.GetCurrentDirectory(), "Resources", "series.json");
string seriesString = File.ReadAllText(seriesFile);

string studiesFile = Path.Combine(Directory.GetCurrentDirectory(), "Resources", "study.json");
string studiesString = File.ReadAllText(studiesFile);

// Deserialize the JSON file to a List<Series>
List<Series> series = JsonSerializer.Deserialize<List<Series>>(seriesString) ?? [];
List<Study> studies = JsonSerializer.Deserialize<List<Study>>(studiesString) ?? [];


// Add Controllers and their dependencies.
builder.Services.AddScoped<StudyService>(provider => {
    return new StudyService(studies);
});
builder.Services.AddScoped<SeriesService>(provider => {
    return new SeriesService(series);
});
builder.Services.AddControllers();

var app = builder.Build();

// Use Swagger only when it's in Dev env.
if (app.Environment.IsDevelopment())
{
app.UseSwagger();
app.UseSwaggerUI( option => {
    option.SwaggerEndpoint("/swagger/v1/swagger.json", "DICOM API V1");
});
}

app.UseCors("AllowSpecificOrigin");
app.MapControllers();

app.Run("http://10.10.20.136:6080");
