import 'package:dave_the_coach_flutter/features/checkins/domain/weekly_checkin.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CheckinFormCard extends StatefulWidget {
  const CheckinFormCard({super.key, required this.onSubmit});

  final Future<void> Function({
    required double bodyweightKg,
    required double sleepHours,
    required int recoveryScore,
    required String notes,
  })
  onSubmit;

  @override
  State<CheckinFormCard> createState() => _CheckinFormCardState();
}

class _CheckinFormCardState extends State<CheckinFormCard> {
  final _formKey = GlobalKey<FormState>();
  final _bodyweightController = TextEditingController();
  final _sleepController = TextEditingController();
  final _notesController = TextEditingController();
  double _recoveryScore = 8;
  bool _saving = false;
  String? _message;

  @override
  void dispose() {
    _bodyweightController.dispose();
    _sleepController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
      _message = null;
    });

    try {
      await widget.onSubmit(
        bodyweightKg: double.parse(_bodyweightController.text.trim()),
        sleepHours: double.parse(_sleepController.text.trim()),
        recoveryScore: _recoveryScore.round(),
        notes: _notesController.text.trim(),
      );
      _message = 'Weekly check-in saved and routed for Dave visibility.';
    } catch (error) {
      _message = '$error';
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF101A31).withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x3328E0FF)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly check-in · ${DateFormat('MMM d, yyyy').format(DateTime.now())}',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _bodyweightController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Bodyweight (kg)'),
              validator: (value) => (double.tryParse(value ?? '') == null)
                  ? 'Enter a valid bodyweight'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _sleepController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Sleep hours'),
              validator: (value) => (double.tryParse(value ?? '') == null)
                  ? 'Enter valid sleep hours'
                  : null,
            ),
            const SizedBox(height: 14),
            Text('Recovery score: ${_recoveryScore.round()}/10'),
            Slider(
              value: _recoveryScore,
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: (value) => setState(() => _recoveryScore = value),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText:
                    'Energy, pain signals, reps hit, movement quality, mindset...',
              ),
            ),
            const SizedBox(height: 14),
            if (_message != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _message!,
                  style: const TextStyle(color: Color(0xFF9BA6C7)),
                ),
              ),
            FilledButton.icon(
              onPressed: _saving ? null : _submit,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(_saving ? 'Saving...' : 'Save weekly check-in'),
            ),
          ],
        ),
      ),
    );
  }
}

class CheckinHistoryCard extends StatelessWidget {
  const CheckinHistoryCard({super.key, required this.checkins});

  final List<WeeklyCheckin> checkins;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF101A31).withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x3328E0FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent check-ins',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          const SizedBox(height: 12),
          if (checkins.isEmpty)
            const Text(
              'No check-ins saved yet. Once an athlete submits one, it will appear here privately.',
              style: TextStyle(color: Color(0xFF9BA6C7), height: 1.5),
            )
          else
            ...checkins
                .take(6)
                .map(
                  (checkin) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0x3328E0FF)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('MMM d, yyyy').format(checkin.weekStart),
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Bodyweight ${checkin.bodyweightKg.toStringAsFixed(1)} kg • Sleep ${checkin.sleepHours.toStringAsFixed(1)} h • Recovery ${checkin.recoveryScore}/10',
                            style: const TextStyle(color: Color(0xFF9BA6C7)),
                          ),
                          if (checkin.notes.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(checkin.notes),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
