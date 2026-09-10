/**
 * Soundbook interest form → Google Sheet
 *
 * Setup:
 * 1. Create a Google Sheet with headers: timestamp | email | idea
 * 2. Extensions → Apps Script, paste this file, Save
 * 3. Deploy → New deployment → Web app
 *    - Execute as: Me
 *    - Who has access: Anyone
 * 4. Copy the /exec URL into interestFormEndpoint in CategoryInterestSheet.swift
 */

function doPost(e) {
  try {
    var data = JSON.parse(e.postData.contents);
    var email = (data.email || "").toString().trim();
    var idea = (data.idea || "").toString().trim();

    if (!email) {
      return json_({ ok: false, error: "email required" });
    }

    var sheet = SpreadsheetApp.getActiveSpreadsheet().getSheets()[0];
    sheet.appendRow([new Date(), email, idea]);

    return json_({ ok: true });
  } catch (err) {
    return json_({ ok: false, error: String(err) });
  }
}

function doGet() {
  return json_({ ok: true, message: "POST email + idea" });
}

function json_(obj) {
  return ContentService
    .createTextOutput(JSON.stringify(obj))
    .setMimeType(ContentService.MimeType.JSON);
}
