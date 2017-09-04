FactoryGirl.define do
  sequence :body do |n|
    "Comment body #{n}"
  end

  factory :comment do
    user
    body
  end

  factory :invalid_comment, class: "Comment" do
    user nil
    body nil
  end
end
