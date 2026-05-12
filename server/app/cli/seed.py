import argparse

from sqlmodel import Session

from app.core.db import engine
from app.modules.attendance.seed import seed_attendance_statuses
from app.modules.evaluations.seed import seed_evaluation_types
from app.modules.schools.seed import seed_levels
from app.modules.subscriptions.seed import seed_subscription_plans


SEEDERS = {
    "schools": seed_levels,
    "evaluations": seed_evaluation_types,
    "attendance": seed_attendance_statuses,
    "subscriptions": seed_subscription_plans,
}


def run_seeder(seeder_name: str) -> None:
    seeder = SEEDERS[seeder_name]
    with Session(engine) as session:
        seeder(session)


def run_all_seeders() -> None:
    for seeder_name in SEEDERS:
        run_seeder(seeder_name)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Ejecuta seeders del proyecto")
    parser.add_argument(
        "target",
        choices=["all", *SEEDERS.keys()],
        help="Seeder a ejecutar: all, schools, evaluations, attendance, subscriptions",
    )
    return parser


def main() -> None:
    parser = build_parser()
    args = parser.parse_args()

    if args.target == "all":
        run_all_seeders()
        print("Seeders ejecutados: all")
        return

    run_seeder(args.target)
    print(f"Seeder ejecutado: {args.target}")


if __name__ == "__main__":
    main()
