table :audits, :truncate

table :devices do |t|
  t.name type: :fixed, string: proc { 'Obfuscated name' }
end
