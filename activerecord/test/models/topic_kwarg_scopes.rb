class Topic
  named_scope :written, lambda { |before:|
    if before
      { :conditions => ['written_on < ?', before] }
    end
  }

  def self.for_author(author_name:)
    scoped conditions: { author_name: author_name }
  end
end
