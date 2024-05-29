using DicomServer.Controller;
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

// Add Controllers and their dependencies.
builder.Services.AddScoped<StudyService>();
builder.Services.AddScoped<SeriesService>();
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

app.Run();
