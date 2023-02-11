module EpubBooksHelper
  def custom_update_title_options
    [["", ""]] + CustomTitleProcessing.public_instance_methods.map{|m| [m,m]}
  end
end
