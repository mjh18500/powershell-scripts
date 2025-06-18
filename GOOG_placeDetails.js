// Retrieves placeDetails from Google Places API 
// API_KEY property should be placed in Project Settings>Script Properties



// Change fields in detailsURL and return results as needed.

function getPlaceDetails(placeName) {
  const apiKey = PropertiesService.getScriptProperties().getProperty('API_KEY');
  const url = `https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=${encodeURIComponent(placeName)}&inputtype=textquery&fields=place_id&key=${apiKey}`;

  const response = UrlFetchApp.fetch(url);
  const data = JSON.parse(response.getContentText());

  // Log full response for debugging (can view in Apps Script → Executions)
  console.log(JSON.stringify(data));

  if (!data.candidates || data.candidates.length === 0) {
    return ["Place not found", "", "", ""];
  }

  const placeId = data.candidates[0].place_id;
  const detailsUrl = `https://maps.googleapis.com/maps/api/place/details/json?place_id=${placeId}&fields=name,formatted_address,formatted_phone_number,rating,website,price_level,opening_hours&key=${apiKey}`;
  const detailsResponse = UrlFetchApp.fetch(detailsUrl);
  const detailsData = JSON.parse(detailsResponse.getContentText());

  const result = detailsData.result;

  const hours = result.opening_hours && result.opening_hours.weekday_text
  ? result.opening_hours.weekday_text.join("\n ")
  : "";

return [
  result.formatted_address || "",
  result.formatted_phone_number || "",
  result.rating || "",
  result.website || "",
  result.price_level || "",
  hours
];
}


function GETPLACEDETAILS(placeName) {
  const details = getPlaceDetails(placeName);
  return details;
}
