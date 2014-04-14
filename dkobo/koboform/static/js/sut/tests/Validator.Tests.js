/* global viewUtils */
/* global it */
/* global describe */
/* global beforeEach */
/* global expect */
/* global sinon */

'use strict';
describe('Validator', function () {
    describe('Specific validators', function (){
        describe('invalidChars', function () {
            it('fails when it should fail', function () {
                expect('travis response to failed tests').toBe('an email notification with the failure message');
            });
            it('should return true when the passed test string contains no invalid chars', function () {
                expect(viewUtils.Validator.__validators.invalidChars('asdf', 'bxc')).toBeTruthy();
            });

            it('should return false when the passed test string contains invalid chars', function () {
                expect(viewUtils.Validator.__validators.invalidChars('asdf', 'bxca')).toBeFalsy();
            });
        });

        describe('unique', function () {
            it('should return true when the passed string is unique in the passed list', function () {
                expect(viewUtils.Validator.__validators.unique('asdf', ['lkjh', 'qwerty'])).toBeTruthy();
            });

            it('should return false when the passed string is not unique in the passed list', function () {
                expect(viewUtils.Validator.__validators.unique('asdf', ['asdf', 'lkjh'])).toBeFalsy();
            });
        });
    });

    describe ('Validator Object', function () {
        var validator,
            validatorStub;

        beforeEach(function () {
            validator =  viewUtils.Validator.create({
                validations: [
                    {
                        name: 'test',
                        failureMessage: 'did not pass test',
                        args: ['test arg']
                    }
                ]
            });
        });

        describe('validate method', function () {
            it('should return true when value passes validation', function () {
                validatorStub = sinon.stub();
                validatorStub.withArgs('test').returns(true);

                viewUtils.Validator.__validators.test = validatorStub;

                expect(validator.validate('test')).toBe(true);
                expect(validatorStub).toHaveBeenCalledOnce();
            });

            it('should return the validation failure message when value fails validation', function () {
                validatorStub = sinon.stub();
                validatorStub.withArgs('test').returns(false);

                viewUtils.Validator.__validators.test = validatorStub;

                expect(validator.validate('test')).toBe('did not pass test');
                expect(validatorStub).toHaveBeenCalledOnce();
            });

            it('should consider additional arguments passed', function () {
                validatorStub = sinon.stub();
                validatorStub.withArgs('test', 'test arg').returns(true);

                viewUtils.Validator.__validators.test = validatorStub;

                expect(validator.validate('test')).toBe(true);
                expect(validatorStub).toHaveBeenCalledOnce();
                expect(validatorStub).toHaveBeenCalledWith('test', 'test arg');

            });

            it('should instantiate the args array when no args are passed', function () {
                validatorStub = sinon.stub();
                validatorStub.withArgs('test').returns(true);
                validator = viewUtils.Validator.create({
                        validations: [
                            {
                                name: 'test',
                                failureMessage: 'did not pass test',
                            }
                        ]
                    });
                viewUtils.Validator.__validators.test = validatorStub;

                expect(validator.validate('test')).toBe(true);
                expect(validatorStub).toHaveBeenCalledOnce();
                expect(validatorStub).toHaveBeenCalledWith('test');
            });
        });
    });

});