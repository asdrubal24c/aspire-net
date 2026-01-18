var builder = DistributedApplication.CreateBuilder(args);

var api = builder.AddProject<Projects.Aspire_Api>("api");

builder.Build().Run();
