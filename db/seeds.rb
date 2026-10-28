# Three themes to open on a fresh checkout. Idempotent: a theme whose name exists is left alone.
{
  "Ocean" => "oklch(0.55 0.2 250)",
  "Forest" => "oklch(0.5 0.13 150)",
  "Sunset" => "oklch(0.62 0.19 45)"
}.each do |name, primary|
  next if Theme.exists?(name: name)

  Themes::Operation::Create.new.call(name: name, primary: primary).value!
end
