import 'package:flutter_riverpod/legacy.dart';
import 'package:formz/formz.dart';
import 'package:mobile/features/auth/presentation/providers/providers.dart';
import 'package:mobile/features/shared/shared.dart';

final personalInfoFormProvider =
    StateNotifierProvider.autoDispose<
      PersonalInfoFormNotifier,
      PersonalInfoFormState
    >((ref) {
      final user = ref.read(authProvider).user;
      final updatePersonalInfoCallback = ref
          .read(authProvider.notifier)
          .updatePersonalInfo;

      return PersonalInfoFormNotifier(
        updatePersonalInfoCallback: updatePersonalInfoCallback,
        initialFirstName: user?.firstName ?? '',
        initialLastName: user?.lastName ?? '',
      );
    });

class PersonalInfoFormNotifier extends StateNotifier<PersonalInfoFormState> {
  final Future<bool> Function(String, String) updatePersonalInfoCallback;

  PersonalInfoFormNotifier({
    required this.updatePersonalInfoCallback,
    required String initialFirstName,
    required String initialLastName,
  }) : super(
         PersonalInfoFormState.fromInitialValues(
           firstName: initialFirstName,
           lastName: initialLastName,
         ),
       );

  void onFirstNameChange(String value) {
    final newFirstName = Name.dirty(value);
    state = state.copyWith(
      firstName: newFirstName,
      isValid: Formz.validate([newFirstName, state.lastName]),
    );
  }

  void onLastNameChange(String value) {
    final newLastName = Name.dirty(value);
    state = state.copyWith(
      lastName: newLastName,
      isValid: Formz.validate([state.firstName, newLastName]),
    );
  }

  Future<void> onFormSubmit() async {
    _touchEveryField();
    if (!state.isValid || !state.hasChanges) return;

    state = state.copyWith(isPosting: true);
    final wasUpdated = await updatePersonalInfoCallback(
      state.firstName.value.trim(),
      state.lastName.value.trim(),
    );

    if (!wasUpdated) {
      state = state.copyWith(isPosting: false);
      return;
    }

    final updatedFirstName = state.firstName.value.trim();
    final updatedLastName = state.lastName.value.trim();
    final validatedFirstName = Name.dirty(updatedFirstName);
    final validatedLastName = Name.dirty(updatedLastName);

    state = state.copyWith(
      firstName: validatedFirstName,
      lastName: validatedLastName,
      initialFirstName: updatedFirstName,
      initialLastName: updatedLastName,
      isFormPosted: false,
      isPosting: false,
      isValid: Formz.validate([validatedFirstName, validatedLastName]),
    );
  }

  void _touchEveryField() {
    final firstName = Name.dirty(state.firstName.value);
    final lastName = Name.dirty(state.lastName.value);

    state = state.copyWith(
      isFormPosted: true,
      firstName: firstName,
      lastName: lastName,
      isValid: Formz.validate([firstName, lastName]),
    );
  }
}

class PersonalInfoFormState {
  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final Name firstName;
  final Name lastName;
  final String initialFirstName;
  final String initialLastName;

  bool get hasChanges {
    return firstName.value.trim() != initialFirstName.trim() ||
        lastName.value.trim() != initialLastName.trim();
  }

  bool get canSubmit => hasChanges && isValid && !isPosting;

  PersonalInfoFormState({
    this.isPosting = false,
    this.isFormPosted = false,
    this.isValid = false,
    this.firstName = const Name.pure(),
    this.lastName = const Name.pure(),
    this.initialFirstName = '',
    this.initialLastName = '',
  });

  factory PersonalInfoFormState.fromInitialValues({
    required String firstName,
    required String lastName,
  }) {
    final firstNameInput = Name.dirty(firstName);
    final lastNameInput = Name.dirty(lastName);

    return PersonalInfoFormState(
      firstName: firstNameInput,
      lastName: lastNameInput,
      initialFirstName: firstName,
      initialLastName: lastName,
      isValid: Formz.validate([firstNameInput, lastNameInput]),
    );
  }

  PersonalInfoFormState copyWith({
    bool? isPosting,
    bool? isFormPosted,
    bool? isValid,
    Name? firstName,
    Name? lastName,
    String? initialFirstName,
    String? initialLastName,
  }) => PersonalInfoFormState(
    isPosting: isPosting ?? this.isPosting,
    isFormPosted: isFormPosted ?? this.isFormPosted,
    isValid: isValid ?? this.isValid,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    initialFirstName: initialFirstName ?? this.initialFirstName,
    initialLastName: initialLastName ?? this.initialLastName,
  );
}
