require 'spec_helper'

module Bravo
  describe Authorization do
    context 'on initialize' do
      context 'with bad path' do
        let(:subject) { described_class.new('20287740027', 'bad/pkey/path', 'bad/cert/path') }

        it 'requires cuit, pkey_path and cert_path' do
          expect { subject }.to raise_exception(ArgumentError)
        end
      end

      context 'with correct attributes' do
        let(:authorization) do
          described_class.new('20287740027', 'spec/fixtures/certs/pkey', 'spec/fixtures/certs/cert.crt')
        end

        it 'returns a valid instance' do
          expect(authorization).to be_a(described_class)
        end

        it 'sets cuit, pkey_path and cert_path instance variables' do
          expect(authorization.cuit).to eq '20287740027'
          expect(authorization.pkey_path).to eq "spec/fixtures/certs/pkey"
          expect(authorization.cert_path).to eq "spec/fixtures/certs/cert.crt"
        end
      end
    end

    context 'when building a new set of credentials' do
      it 'stores the new auth in the authorizations instance variable' do
        expect do
          described_class.build('20287740027', 'spec/fixtures/certs/pkey', 'spec/fixtures/certs/cert.crt')
        end.to change(described_class.credentials.authorizations, :count).by(1)
      end
    end

    context 'when requested for credentials for a cuit' do
      context 'when there are none for that cuit' do
        before do
          described_class.credentials.authorizations = []
        end

        it 'raises an error' do
          expect { described_class.for('some_cuit') }.to raise_exception(::Bravo::MissingCredentials,
            'missing credentials for some_cuit')
        end
      end

      context 'when there are credentials for that cuit' do
        let(:authorization) { valid_authorization }

        it 'returns the authorization' do
          expect(described_class.for(authorization.cuit)).to eq(authorization)
        end
      end
    end

    context 'a valid instance' do
      subject(:authorization) { valid_authorization }

      context 'when checking if its authorized' do
        it 'returns false for unauthorized credentials' do
          expect(authorization.authorized?).to be_falsey
        end
      end

      context 'when calling the login method' do
        it 'sets the login data attributes', vcr: { cassette_name: 'valid_login' } do
          expect(authorization.authorize!).to be_truthy

          expect(authorization.token).to be_truthy
          expect(authorization.sign).to be_truthy
          expect(authorization.created_at).to be_truthy
          expect(authorization.expires_at).to be_truthy

          expect(authorization.authorized?).to be_truthy
        end
      end
    end

    context 'when credentials are current' do
      subject(:authorization) { described_class.for('20287740027') }

      before do
        timestamp = Time.new

        described_class.build('20287740027', 'spec/fixtures/certs/pkey', 'spec/fixtures/certs/cert.crt')

        subject.token = 'token'
        subject.sign = 'sign'
        subject.expires_at = timestamp + 3600
        subject.created_at = timestamp - 7200

        described_class.credentials.store subject
      end

      it 'builds the auth hash from memory' do
        expect { subject.auth_hash }.not_to change(subject, :created_at)
      end
    end

    context 'when credentials are expired' do
      subject(:authorization) do
        described_class.build('20287740027', 'spec/fixtures/certs/pkey', 'spec/fixtures/certs/cert.crt')
      end

      it 'renews the credentials', vcr: { cassette_name: 'valid_login' }do
        expect { subject.auth_hash }.to change(subject, :created_at)
      end
    end

    def valid_authorization
      described_class.build('20287740027', 'spec/fixtures/certs/pkey', 'spec/fixtures/certs/cert.crt')
    end
  end
end
