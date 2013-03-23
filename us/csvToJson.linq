<Query Kind="Statements">
  <Reference>&lt;RuntimeDirectory&gt;\System.Core.dll</Reference>
  <NuGetReference>Newtonsoft.Json</NuGetReference>
  <Namespace>Newtonsoft.Json</Namespace>
  <Namespace>Newtonsoft.Json.Linq</Namespace>
  <Namespace>Newtonsoft.Json.Serialization</Namespace>
  <Namespace>System.Dynamic</Namespace>
</Query>

var lines = File
    .ReadAllLines(@"C:\Users\boris\Dropbox\Algorithms\geojson\us\crime.csv")
    .Select (l => l.Split(','))
    .ToList();
    
string [] keys = lines.First();
lines.RemoveAt(0);
string state = string.Empty;
Dictionary<string, dynamic> recs = new Dictionary<string, dynamic>();
dynamic record = null;

foreach (var line in lines)
{
    dynamic city = new ExpandoObject();
    var dict = city as IDictionary<String, Object>;
    
    for(int i = 0; i < keys.Length; i++)
    {
        string key = keys[i];
        switch (i)
        {
            case 0:
                if (!string.IsNullOrWhiteSpace(line[0]) && line[0] != state)
                {
                    state = line[0];
                    
                    record = new ExpandoObject();
                    var rec_dict = record as IDictionary<String, Object>;
                    record.id = state.Split(' ').Aggregate((a, e)=> a + "_" + e);
                    record.name = state.Split(' ').Select(s => s[0].ToString() + s.Substring(1).ToLowerInvariant()).Aggregate((a, e) => a + " " + e);
                    record.value = 0;
                    record.violent = 0;
                    record.property = 0;
                    record.cities = new List<dynamic>();
                    
                    recs.Add(state, record);
                }
                break;
            case 1:
                dict[key] = line[i];
                break;
            default:
                int result;
                if(int.TryParse(line[i], out result))
                {
                    dict[key] = result;
                }
                else
                {
                    dict[key] = 0;
                }
                break;
        }
    }

    record.value = (int)record.value + (int)city.population;
    record.violent = (int)record.violent + (int)city.violent;
    record.property = (int)record.property + (int)city.property;
    record.group = 100000f * ((float) record.violent / (float) record.value);
    (record.cities as List<dynamic>).Add(city);
}

var json = JObject.FromObject(recs);
String jS = json.ToString();

File.WriteAllText(@"C:\Users\boris\Dropbox\Algorithms\geojson\us\crime.json", jS);