local metadata_labels = {
  ["Document Type:"] = true,
  ["Version:"] = true,
  ["Status:"] = true,
  ["Last Reviewed:"] = true,
  ["Approved By:"] = true,
  ["Applies To:"] = true,
  ["Jurisdiction:"] = true,
}

local function starts_with_any(text, prefixes)
  for _, prefix in ipairs(prefixes) do
    if text:match("^" .. prefix) then
      return true
    end
  end
  return false
end

local function starts_with_metadata_label(text)
  for label, _ in pairs(metadata_labels) do
    if text:match("^" .. label) then
      return true
    end
  end
  return false
end

function Pandoc(doc)
  local cleaned = {}
  local doc_title = pandoc.utils.stringify(doc.meta.title or "")
  if doc_title == "" then
    for _, block in ipairs(doc.blocks) do
      if block.t == "Header" and block.level == 1 then
        doc_title = pandoc.utils.stringify(block)
        break
      end
    end
  end
  local skipping_internal = false
  local dropping_tail = false
  local skip_until_text = nil
  local include_matching_block = false

  local is_media_form = doc_title:match("Media and Photography")
  local is_adult_media_form = doc_title:match("Adults")
  local is_parent_programme_form = doc_title:match("Parent and Guardian Permission Form")
  local is_student_form = doc_title:match("Student Participation Agreement")

  for _, block in ipairs(doc.blocks) do
    local text = pandoc.utils.stringify(block)

    if dropping_tail then
      -- Drop all remaining blocks after the Change Log heading.
    elseif skip_until_text ~= nil then
      if text == skip_until_text then
        skip_until_text = nil
        if include_matching_block then
          table.insert(cleaned, block)
        end
        include_matching_block = false
      end
    elseif skipping_internal then
      if block.t == "HorizontalRule" then
        skipping_internal = false
      end
    elseif starts_with_metadata_label(text) then
      -- Drop internal document-management metadata from participant-facing DOCX files.
    elseif starts_with_any(text, {
      "School:",
      "School / Organisation:",
      "Programme:",
      "For full details on privacy, data use, and all AIWA policies, visit",
      "Entered in register:",
    }) then
      -- Drop header/footer admin lines that do not help the signer.
    elseif block.t == "Para" and text == "For AIWA Use Only" then
      skipping_internal = true
    elseif is_adult_media_form and text == "Audio Recordings" then
      skip_until_text = "My Name"
      include_matching_block = true
    elseif is_media_form and block.t == "Header" and text:match("^MEDIA AND PHOTOGRAPHY") then
      -- The document title already provides this label.
    elseif is_parent_programme_form and text:match("^Please complete the section below and return to the school") then
      -- Drop facilitator/process instructions from the signer-facing output.
    elseif is_parent_programme_form and text:match("^If you gave permission verbally with a facilitator") then
      -- Keep only the witness signature lines below.
    elseif is_student_form and block.t == "Header" and text == "Digital Tools Used in This Programme" then
      skip_until_text = "Questions and Concerns"
      include_matching_block = true
    elseif is_student_form and starts_with_any(text, { "My Class:", "My School:" }) then
      -- Drop redundant student fields from the public form.
    elseif block.t == "Header" and text == "Change Log" then
      dropping_tail = true
    elseif block.t == "HorizontalRule" then
      -- Remove rules so the reference DOCX styles control spacing instead.
    else
      table.insert(cleaned, block)
    end
  end

  if skip_until_text ~= nil then
    error("Form cleanup expected to resume at block: " .. skip_until_text)
  end

  return pandoc.Pandoc(cleaned, doc.meta)
end
