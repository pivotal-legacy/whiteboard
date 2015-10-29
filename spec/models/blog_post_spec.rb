require 'rails_helper'

describe BlogPost do
  describe '#post_hash' do
    before do
      subject.title = 'title'
      subject.body = 'description'
      subject.keywords = 'keywords'
      subject.categories = 'categories'
    end

    it 'returns a properly formed hash' do
      expect(subject.post_hash).to eq ({
        'title' => 'title',
        'description' => 'description',
        'mt_keywords' => 'keywords',
        'categories' => 'categories'
      })
    end
  end

  describe '#keywords' do
    it 'returns keywords if set' do
      subject.keywords = 'keywords'
      expect(subject.keywords).to eq 'keywords'
    end

    it 'returns [] if no keywords were set' do
      expect(subject.keywords).to eq []
    end
  end

  describe '#categories' do
    it 'returns categories if set' do
      subject.categories = 'categories'
      expect(subject.categories).to eq 'categories'
    end

    it 'returns ["standup"] if no categories were set' do
      expect(subject.categories).to eq ['standup']
    end
  end
end
