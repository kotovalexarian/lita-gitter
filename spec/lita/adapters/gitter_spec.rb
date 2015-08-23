describe Lita::Adapters::Gitter, lita: true do
  subject { described_class.new(robot) }

  let(:robot) { Lita::Robot.new(registry) }
  let(:connection) { instance_double('Lita::Adapters::Gitter::Connection') }
  let(:token) { '1234567890abcdef1234567890abcdef12345678' }
  let(:room_id) { '1234567890abcdef12345678' }

  before do
    registry.register_adapter(:gitter, described_class)
    registry.config.adapters.gitter.token = token
    registry.config.adapters.gitter.room_id = room_id

    allow(described_class::Connection).to receive(:new).with(robot, subject.config).and_return(connection)
    allow(connection).to receive(:run)
  end

  it 'registers with Lita' do
    expect(Lita.adapters[:gitter]).to eql(described_class)
  end

  describe '#run' do
    it 'starts the stream connection' do
      expect(connection).to receive(:run)

      subject.run
    end

    it 'does nothing if the stream connection is already created' do
      expect(connection).to receive(:run).once

      subject.run
      subject.run
    end
  end
end
