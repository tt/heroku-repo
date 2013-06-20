class Hash
  def to_query_string
    self.inject('') do |query_string, pair|
      query_string << '&' unless query_string.empty?
      query_string << "#{URI.encode(pair.first.to_s)}=#{URI.encode(pair.last.to_s)}"
    end
  end
end
